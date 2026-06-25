# AWS Three-Tier Architecture

> Production-grade three-tier web application infrastructure on AWS, provisioned entirely with Terraform.

## Architecture Overview

```
                          ┌─────────────────────────────────────┐
                          │           Internet Gateway           │
                          └──────────────┬──────────────────────┘
                                         │
                          ┌──────────────▼──────────────────────┐
                          │      Application Load Balancer       │
                          │         (Public Subnets)             │
                          └──────────┬──────────────────────────┘
                                     │
               ┌─────────────────────┼─────────────────────┐
               │                     │                      │
   ┌───────────▼──────┐  ┌───────────▼──────┐  ┌───────────▼──────┐
   │   EC2 Web Tier   │  │   EC2 Web Tier   │  │   EC2 Web Tier   │
   │  (Auto Scaling)  │  │  (Auto Scaling)  │  │  (Auto Scaling)  │
   │   AZ-1a          │  │   AZ-1b          │  │   AZ-1c          │
   └───────────┬──────┘  └───────────┬──────┘  └───────────┬──────┘
               │                     │                      │
               └─────────────────────┼─────────────────────┘
                                     │
                          ┌──────────▼──────────────────────────┐
                          │         NAT Gateway                  │
                          │      (Private Subnet Egress)         │
                          └──────────┬──────────────────────────┘
                                     │
               ┌─────────────────────┼─────────────────────┐
               │                     │                      │
   ┌───────────▼──────┐  ┌───────────▼──────┐              │
   │  RDS Primary     │  │  RDS Standby     │              │
   │  (Multi-AZ)      │  │  (Failover)      │              │
   │  AZ-1a           │  │  AZ-1b           │              │
   └──────────────────┘  └──────────────────┘              │
                                                            │
                                              ┌─────────────▼──────┐
                                              │   CloudWatch        │
                                              │   Monitoring        │
                                              └────────────────────┘
```

## Problem Statement

Organizations need scalable, fault-tolerant web application infrastructure that handles traffic spikes automatically without manual intervention, while keeping costs optimized during low-traffic periods.

## Solution

A fully automated three-tier architecture provisioned entirely through Terraform IaC:

- **Presentation Tier**: Auto Scaling Group of EC2 instances behind an Application Load Balancer across 3 Availability Zones
- **Application Tier**: Business logic layer with private subnet isolation and NAT Gateway egress
- **Data Tier**: RDS MySQL with Multi-AZ deployment for automatic failover under 60 seconds

## Key Outcomes

- Auto-scaling handles traffic spikes with zero manual intervention
- Multi-AZ RDS provides database high availability with automatic failover
- All infrastructure reproducible from a single `terraform apply` command
- CloudWatch dashboards provide full observability across all tiers

## Technologies

| Category | Tools |
|---|---|
| Cloud | AWS (EC2, RDS, ALB, VPC, CloudWatch) |
| IaC | Terraform |
| Networking | VPC, Subnets, Security Groups, NAT Gateway |
| Database | RDS MySQL Multi-AZ |
| Monitoring | CloudWatch Metrics & Alarms |

## Repository Structure

```
aws-three-tier-arch/
├── terraform/
│   ├── main.tf
│   ├── vpc.tf
│   ├── ec2.tf
│   ├── rds.tf
│   ├── alb.tf
│   ├── autoscaling.tf
│   ├── cloudwatch.tf
│   ├── variables.tf
│   └── outputs.tf
├── architecture/
│   └── diagram.png
└── README.md
```

## Author

**Sugandha Vashishtha** — Cloud & Site Reliability Engineer  
[LinkedIn](https://linkedin.com/in/sugandha-vashishtha) · [Portfolio](https://sugandha.dev)
