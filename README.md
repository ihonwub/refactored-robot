# Refactored Robot - GitOps Demo POC

A proof-of-concept demonstrating GitOps practices using ArgoCD with Argo Rollouts for automated multi-environment deployments.

## Overview

This demo repository showcases an automated GitOps workflow that promotes container images through dev → QA → production environments using:

- **ArgoCD ApplicationSets** for multi-environment management
- **Argo Rollouts** for Blue/Green and Canary deployment strategies
- **Automated image promotion** with Git notes metadata tracking
- **Rendered manifests pattern** for environment-specific configurations

**Image Source**: Container images are built and pushed from the [curly-spork repository](https://github.com/ihonwub/curly-spork). Changes to that repository trigger new builds that flow through this promotion pipeline.

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

## How It Works

### Image Promotion Pipeline
1. **Trigger**: New images built in [curly-spork](https://github.com/ihonwub/curly-spork) are promoted via Git notes metadata
2. **Dev → QA**: Automatic promotion with direct commit
3. **QA → Prod**: Creates pull request requiring manual approval

### Rendered Manifests Pattern
- Helm templates rendered to environment-specific branches (`env/dev`, `env/qa`, `env/prod`)
- ArgoCD monitors each branch for automatic deployment
- Environment isolation with dedicated namespaces

### Git Notes Tracking
```bash
# Example metadata attached to commits
image: ghcr.io/ihonwub/curly-spork:dd8f160ea514c068a1d6273ba69a57ccc6deaba2
env: qa
```

## Environment Configuration

| Environment | Strategy | Auto-Promotion | Resources |
|-------------|----------|----------------|-----------|
| **Dev** | Rolling Update | N/A | 200m CPU, 256Mi RAM |
| **QA** | Blue/Green | 30s delay | 300m CPU, 512Mi RAM |
| **Prod** | Blue/Green | Manual only | 500m CPU, 1Gi RAM |

## Quick Start

### Prerequisites
- ArgoCD + Argo Rollouts installed
- GitHub PAT configured as `DEPLOY_PAT` secret

### Setup
1. Apply `apps.yaml` to your ArgoCD namespace
2. Push changes trigger manifest rendering and deployment
3. Image updates from [curly-spork](https://github.com/ihonwub/curly-spork) flow through promotion pipeline

### Production Promotion
Production deployments require manual approval via pull request review and merge.

## References

This POC was built using these resources:

- **[Argo Rollouts Workshop](https://openshiftdemos.github.io/argo-rollouts-workshop/argo-rollouts-workshop/main/index.html)** - Deployment strategies and best practices
- **[The Rendered Manifests Pattern](https://akuity.io/blog/the-rendered-manifests-pattern)** - Environment-specific manifest rendering approach
- **[GitOps and Argo CD](https://youtu.be/aRKrDmqYLCE?si=-DqfHmyR8sEuE0l9)** - GitOps principles and ArgoCD patterns

---

*This is a proof-of-concept demonstration of GitOps practices for educational and demo purposes.*