# Refactored Robot - GitOps Demo

A demonstration of GitOps practices using ArgoCD with Argo Rollouts for advanced deployment strategies across multiple environments.

## Overview

This repository showcases a complete GitOps workflow that automatically promotes container images through development, QA, and production environments using:

- **ArgoCD ApplicationSets** for multi-environment management
- **Argo Rollouts** for advanced deployment strategies (Blue/Green and Canary)
- **Automated image promotion** with commit tracking via Git notes
- **Helm templating** for environment-specific configurations

## Repository Structure

```
.
├── apps.yaml                     # ArgoCD Application bootstrap (app-of-apps pattern)
├── appsets/
│   └── rolloutsdemo-appset.yaml  # ApplicationSet for multi-environment deployment
├── rolloutdemo/                  # Helm chart for the demo application
│   ├── Chart.yaml
│   ├── templates/
│   │   ├── rollout.yaml          # Argo Rollout configuration
│   │   ├── services.yaml         # Kubernetes services
│   │   ├── routes.yaml           # OpenShift routes
│   │   └── analysis-template.yaml # Rollout analysis template
│   └── values.yaml               # Default Helm values
├── values/
│   ├── values.common.yaml        # Common configuration across environments
│   └── envs/
│       ├── dev.yaml              # Development environment overrides
│       ├── qa.yaml               # QA environment overrides
│       └── prod.yaml             # Production environment overrides
└── .github/workflows/
    ├── promote-images.yaml       # Automated image promotion workflow
    └── render-manifests.yaml    # Helm manifest rendering workflow
```

## Automated Workflows

### 1. Image Promotion Pipeline (`promote-images.yaml`)

This workflow automatically promotes container images between environments based on Git notes metadata:

- **Trigger**: Push to `main` branch
- **Metadata Extraction**: Reads Git notes for image and environment information
- **Dev → QA Promotion**: Automatically updates QA environment and commits changes
- **QA → Prod Promotion**: Creates pull request for manual review and approval

#### Key Features:

- Uses Git notes to track image metadata: `image: ghcr.io/ihonwub/curly-spork:tag` and `env: environment`
- Automatic promotion from dev to QA with direct commit
- Manual approval required for production deployments via pull requests
- Preserves Git notes across promotions for full traceability

#### Promotion Flow:
```
Dev Environment → (Auto) → QA Environment → (Manual PR) → Production
```

### 2. Manifest Rendering (`render-manifests.yaml`)

Renders Helm templates for each environment and commits to dedicated branches:

- **Environments**: dev, qa, prod (matrix strategy)
- **Output**: Renders manifests to `env/{environment}` branches
- **Validation**: Ensures rendered YAML is valid before committing
- **ArgoCD Integration**: Each environment branch is monitored by ArgoCD applications

## Environment Configuration

### Common Configuration (`values.common.yaml`)
- Base image: `ghcr.io/ihonwub/curly-spork`
- Rollout strategies (Blue/Green and Canary)
- Resource limits and probes
- Service configuration

### Environment-Specific Overrides

| Environment | Replicas | Strategy | Auto-Promotion | Resources |
|-------------|----------|----------|----------------|-----------|
| **Dev** | 2 | Rolling Update | N/A | 200m CPU, 256Mi RAM |
| **QA** | 2 | Blue/Green | Enabled (30s) | 300m CPU, 512Mi RAM |
| **Prod** | 3 | Blue/Green | Disabled (Manual) | 500m CPU, 1Gi RAM |

## ArgoCD Integration

### Application Bootstrap
The `apps.yaml` file implements the "app-of-apps" pattern, creating a bootstrap application that manages the ApplicationSet.

### ApplicationSet Configuration
The ApplicationSet (`rolloutsdemo-appset.yaml`) automatically creates ArgoCD applications for each environment:

- **Source**: Environment-specific branches (`env/dev`, `env/qa`, `env/prod`)
- **Sync Policy**: Automated with prune and self-heal enabled
- **Namespaces**: Environment-specific (`dev`, `qa`, `prod`)


## Git Notes for Metadata Tracking

The system uses Git notes to track deployment metadata:

```bash
# Example Git notes content
image: ghcr.io/ihonwub/curly-spork:dd8f160ea514c068a1d6273ba69a57ccc6deaba2
env: qa
```

This enables:
- **Traceability**: Track which image versions are deployed where
- **Automation**: Trigger appropriate promotion workflows
- **Auditability**: Full history of deployments and promotions

## Getting Started

### Prerequisites
- ArgoCD installed in your Kubernetes cluster
- Argo Rollouts controller installed
- GitHub repository access with appropriate secrets configured

### Setup

1. **Configure Secrets**: Ensure `DEPLOY_PAT` secret is configured in GitHub Actions
2. **Install Bootstrap App**: Apply the `apps.yaml` to your ArgoCD namespace
3. **Initial Deployment**: Push changes to trigger the manifest rendering workflow

### Manual Operations

#### Promote to Production
1. The promotion workflow creates a PR for production deployments
2. Review the changes in the pull request
3. Merge the PR to deploy to production
4. ArgoCD will automatically sync the changes

#### Rollback
Use ArgoCD UI or CLI to rollback to previous revisions:
```bash
argocd app rollback rollout-prod --revision 2
```

## Security and Best Practices

- **Manual Production Approval**: Production deployments require manual review
- **Smoke Tests**: Automated validation before promotion in critical environments
- **Resource Limits**: Environment-appropriate resource allocation
- **Namespace Isolation**: Each environment runs in its own namespace
- **Revision History**: Configurable retention for rollback capabilities

## Monitoring and Observability

The configuration includes comprehensive health checks:

- **Liveness Probes**: Application health monitoring
- **Readiness Probes**: Traffic routing decisions
- **Rollout Analysis**: Automated success/failure detection during deployments


This GitOps demo showcases best practices for automated, safe, and traceable deployments across multiple environments.