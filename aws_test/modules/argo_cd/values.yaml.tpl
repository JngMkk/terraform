global:
  nodeSelector:
    role: devops

server:
  autoscaling:
    maxReplicas: 2
  
  extraArgs:
      - --insecure

  ingress:
    enabled: true

    annotations:
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/target-group-attributes: stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=60
      alb.ingress.kubernetes.io/certificate-arn: ${ aws_acm_arn }
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
      alb.ingress.kubernetes.io/ssl-redirect: 443
    
    ingressClassName: alb

    hosts:
      - ${ argocd_server_host }

    tls:
      - secretName: argocd-secret
        hosts:
          - ${ argocd_server_host }
