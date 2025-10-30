resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "dashboard-${var.project_name}-${var.env}"

  dashboard_body = jsonencode({
    widgets = [
      # Backend ALB Metrics
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.backend_alb_arn_suffix, { stat = "Average", label = "Response Time" }],
            [".", "RequestCount", ".", ".", { stat = "Sum", label = "Requests" }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { stat = "Sum", label = "5XX Errors", yAxis = "right" }],
            [".", "HTTPCode_Target_4XX_Count", ".", ".", { stat = "Sum", label = "4XX Errors", yAxis = "right" }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "Backend ALB"
          period = 300
        }
      },
      # Frontend ALB Metrics
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.frontend_alb_arn_suffix, { stat = "Average", label = "Response Time" }],
            [".", "RequestCount", ".", ".", { stat = "Sum", label = "Requests" }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { stat = "Sum", label = "5XX Errors", yAxis = "right" }],
            [".", "HTTPCode_Target_4XX_Count", ".", ".", { stat = "Sum", label = "4XX Errors", yAxis = "right" }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "Frontend ALB"
          period = 300
        }
      },
      # # Backend Health
      # {
      #   type   = "metric"
      #   width  = 12
      #   height = 6
      #   properties = {
      #     metrics = [
      #       ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.backend_tg_arn_suffix, "LoadBalancer", var.backend_alb_arn_suffix, { stat = "Average", label = "Healthy" }],
      #       [".", "UnHealthyHostCount", ".", ".", ".", ".", { stat = "Average", label = "Unhealthy" }]
      #     ]
      #     view   = "timeSeries"
      #     region = var.aws_region
      #     title  = "Backend Target Health"
      #     period = 60
      #   }
      # },
      # # Frontend Health
      # {
      #   type   = "metric"
      #   width  = 12
      #   height = 6
      #   properties = {
      #     metrics = [
      #       ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.frontend_tg_arn_suffix, "LoadBalancer", var.frontend_alb_arn_suffix, { stat = "Average", label = "Healthy" }],
      #       [".", "UnHealthyHostCount", ".", ".", ".", ".", { stat = "Average", label = "Unhealthy" }]
      #     ]
      #     view   = "timeSeries"
      #     region = var.aws_region
      #     title  = "Frontend Target Health"
      #     period = 60
      #   }
      # },
      # Backend Instances CPU
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            for instance_id in var.backend_instance_ids :
            ["AWS/EC2", "CPUUtilization", "InstanceId", instance_id, { stat = "Average", label = instance_id }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "Backend CPU"
          period = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      # Frontend Instances CPU
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            for instance_id in var.frontend_instance_ids :
            ["AWS/EC2", "CPUUtilization", "InstanceId", instance_id, { stat = "Average", label = instance_id }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "Frontend CPU"
          period = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      # RDS CPU
      {
        type   = "metric"
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id, { stat = "Average" }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "RDS CPU"
          period = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      # RDS Connections
      {
        type   = "metric"
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_instance_id, { stat = "Average" }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "RDS Connections"
          period = 300
        }
      },
      # RDS Storage
      {
        type   = "metric"
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.rds_instance_id, { stat = "Average" }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "RDS Free Storage"
          period = 300
        }
      }
    ]
  })
}
