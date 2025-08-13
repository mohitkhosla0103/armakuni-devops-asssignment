resource "aws_lb" "alb" {
  name                = var.alb_name
  load_balancer_type  = "application"
  internal            = var.is_internal
  subnets             = var.alb_subnets
  security_groups     = var.alb_security_groups
  idle_timeout        = var.idle_timeout
  
    tags = merge(
    {
      Name = var.alb_name
   
    },
    var.extra_tags
  )
  
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
      tags = merge(
    {
      
   
    },
    var.extra_tags
  )
}

# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = "443"
#   protocol          = "HTTPS"

    
#   //certificate_arn   = var.certificate_arn
  
#   default_action {
#     type             = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       status_code = "404"
#     }
#   }
#       tags = merge(
#     {
      
   
#     },
#     var.extra_tags
#   )
# }



