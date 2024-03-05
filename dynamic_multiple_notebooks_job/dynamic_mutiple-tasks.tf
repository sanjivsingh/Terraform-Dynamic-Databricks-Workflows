data "databricks_current_user" "sanjiv" {}
data "databricks_spark_version" "latest" {}
data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}
data "databricks_node_type" "smallest" {    
  local_disk = true
}

data "external" "parse_onboarding_json" {
  program = ["python", "onboarding_json_parser.py"]

  query = {
    onboarding_json   = "${var.onboarding_json}"
  }
}

# provisioning notebooks

# create a multi-task job
resource "databricks_job" "this" {
  name = "${jsondecode(data.external.parse_onboarding_json.result.job_name)}(Job with Dynamic Notebooks)"
  
  job_cluster {
    job_cluster_key = "multi_task_job_cluster"
    new_cluster {
      num_workers   = 2
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
	  aws_attributes {
        first_on_demand  = 1  
        zone_id   = "us-east-1c"
      }
    }
  }
  
  schedule {
    quartz_cron_expression = "0 0 0 ? 1/1 * *"
    timezone_id = "UTC"
   }

  email_notifications {
    on_failure = [ "sanjiv.singh@XXXXXX.com" ]
    on_start = [ "sanjiv.singh@XXXXXX.com" ]
    on_success = [ "sanjiv.singh@XXXXXX.com" ]
  }

  dynamic "task" {
    for_each   = jsondecode(data.external.parse_onboarding_json.result.notebooks)
    content {
      task_key = "notebook_${task.key}"

	  # job cluster for this task. This cluster is specifically
      # created for this job
      job_cluster_key = "multi_task_job_cluster"
	  
	  notebook_task {
        notebook_path = "${data.databricks_current_user.sanjiv.home}/Terraform_Auto/${task.value}"
      }
	  
      dynamic "depends_on" {
        for_each = jsondecode(data.external.parse_onboarding_json.result.notebooks_dependency)[task.key]
        content {
          task_key = "notebook_${depends_on.value}"
        }
      }
    }
  }
  
}

output "job_url" {
  value = databricks_job.this.url
}