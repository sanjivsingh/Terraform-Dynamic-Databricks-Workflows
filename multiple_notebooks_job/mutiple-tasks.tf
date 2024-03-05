data "databricks_current_user" "sanjiv" {}
data "databricks_spark_version" "latest" {}
data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}
data "databricks_node_type" "smallest" {    
  local_disk = true
}

# create a multi-task job
resource "databricks_job" "this" {
  name = "Job with Multiple notebooks"

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

  task {
    task_key = "notebook-1"

    # job cluster for this task. This cluster is specifically
    # created for this job
    job_cluster_key = "multi_task_job_cluster"

    notebook_task {
      notebook_path = "${data.databricks_current_user.sanjiv.home}/Terraform_Auto/notebooks/notebook-1"
    }
  }

  task {
    task_key = "notebook-2"
    # this task will only run after task 1
    depends_on {
      task_key = "notebook-1"
    }

    notebook_task {
      notebook_path = "${data.databricks_current_user.sanjiv.home}/Terraform_Auto/notebooks/notebook-2"
    }

    # job cluster for this task. This cluster is specifically
    # created for this job
    job_cluster_key = "multi_task_job_cluster"

  }
  
  task {
    task_key = "notebook-3"
    # this task will only run after task 2
    depends_on {
      task_key = "notebook-2"
    }

    notebook_task {
      notebook_path = "${data.databricks_current_user.sanjiv.home}/Terraform_Auto/notebooks/notebook-3"
    }

    # job cluster for this task. This cluster is specifically
    # created for this job
    job_cluster_key = "multi_task_job_cluster"
  }

}

output "job_url" {
  value = databricks_job.this.url
}