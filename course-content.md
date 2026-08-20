# Azure Bicep with Azure DevOps

**Duration:** 6 Days (48 Hours)

## Pre-requisite

### Mandatory

* Azure Portal navigation
* Resource Groups and Regions
* Basic VNet & VM awareness
* Azure CLI basics (`az login`, `az group create`)
* Git basics (`clone`, `commit`, `push`)

---

# DAY 1 – Azure Bicep Fundamentals

## Module 1.1 – IaC & Bicep Basics

* Infrastructure as Code fundamentals
* Why Bicep over ARM templates
* Declarative deployment model
* Azure Resource Manager basics
* Bicep file structure
* Resource declaration syntax
* Idempotent deployments

### Hands-on Lab 1 – Core Bicep Workflow

**Goal:** Write and deploy a basic Bicep template safely

* Create a Resource Group
* Write a Bicep file to deploy:

  * Storage Account
* Deploy using Azure CLI
* Modify SKU and redeploy
* Observe idempotent behavior
* Cleanup resources

**Covers:** syntax, tooling, deployment, redeployment, troubleshooting

## Module 1.2 – Tooling & Validation

* Azure CLI
* Bicep CLI
* VS Code Bicep extension
* Linting and formatting

### Hands-on Lab 2 – Validation & Errors

**Goal:** Build confidence in troubleshooting

* Intentionally introduce syntax errors
* Observe linter warnings
* Fix deployment errors
* Validate deployment success

---

# DAY 2 – Parameters, Variables & Modules

## Module 2.1 – Parameters & Validation

* Parameters and data types
* Default values
* Allowed values
* Input validation
* Parameter files

### Hands-on Lab 1 – Environment-Ready Template

**Goal:** One template, multiple environments

* Convert hardcoded values to parameters
* Add minLength and maxLength validation
* Create dev and test parameter files
* Deploy using parameter files

**Covers:** parameters, validation, environments, error prevention

## Module 2.2 – Variables, Outputs & Modules

* Variables
* Naming conventions
* Outputs
* Module structure
* Local modules

### Hands-on Lab 2 – Modular Deployment

**Goal:** Build reusable Bicep code

* Create a storage module
* Use variables for naming
* Expose outputs
* Reuse module twice in main template

**Covers:** variables, outputs, modules, reuse

---

# DAY 3 – Real-World Infrastructure Deployment

## Module 3.1 – Networking with Bicep

* VNet design basics
* Subnets
* NSG overview
* Dependencies

### Hands-on Lab 1 – Network Foundation

**Goal:** Deploy a complete but simple network

* Deploy VNet
* Deploy two subnets
* Deploy NSG
* Associate NSG with subnet

**Covers:** dependencies, loops (light), network resources

## Module 3.2 – Compute & Secure Patterns

* VM components
* NICs and disks
* Admin credentials
* Secret handling risks
* Key Vault integration pattern (theory only)

### Hands-on Lab 2 – Compute on Existing Network

**Goal:** Deploy compute safely

* Reference existing VNet
* Deploy VM into subnet
* Parameterize VM size
* Validate deployment

**Covers:** existing resources, compute, secure patterns

---

# DAY 4 – Azure DevOps Repositories & Branching Strategies

## Module 4.1 – Azure DevOps Repository Management

* Azure Repos overview
* Repository structure for IaC projects
* Git workflow in Azure DevOps
* Branch creation and management
* Pull Request workflow
* Code review fundamentals
* Repository permissions overview

### Hands-on Lab 1 – Repository Setup & Collaboration

**Goal:** Manage Bicep code using Azure Repos

* Create Azure DevOps project
* Create Azure Repos repository
* Clone repository locally
* Push existing Bicep code
* Create feature branch
* Raise and complete Pull Request

**Covers:** repositories, collaboration workflow, PR validation

## Module 4.2 – Branching Strategies for IaC

* Main, feature and release branches
* Branching strategy concepts
* Environment-based branching approach
* Merge conflict basics
* Commit and branching best practices
* Version control for infrastructure code

### Hands-on Lab 2 – Branching Workflow

**Goal:** Implement controlled infrastructure changes

* Create multiple feature branches
* Simulate parallel code changes
* Resolve merge conflicts
* Merge validated code to main branch
* Track commit history

**Covers:** branching models, merge handling, collaboration practices

---

# DAY 5 – Azure DevOps CI/CD for Bicep

## Module 5.1 – Azure DevOps Pipelines

* Azure DevOps pipelines overview
* YAML pipeline structure
* Service Connection concept
* Pipeline stages overview
* What-If deployments

### Hands-on Lab 1 – CI Validation Pipeline

**Goal:** Validate Bicep deployments through CI pipeline

* Create YAML validation pipeline
* Run Bicep build validation
* Run What-If deployment
* Validate deployment outputs

**Covers:** CI workflow, validation, deployment checks

## Module 5.2 – Continuous Deployment for Bicep

* Deployment stages
* Environment approvals (conceptual)
* Dev environment deployments
* Pipeline troubleshooting basics
* Secure deployment considerations

### Hands-on Lab 2 – CI/CD Deployment

**Goal:** Deploy infrastructure through Azure DevOps

* Use pre-provisioned Service Connection
* Configure deployment stage
* Deploy to dev environment
* Validate deployment in Azure Portal
* Re-run deployment after updates

**Covers:** CI/CD, deployment automation, validation workflow

---

# DAY 6 – Governance & Capstone

## Module 6.1 – Governance Basics

* Tagging standards
* Naming standards
* Enterprise governance overview
* Policy-driven deployments
* Compliance considerations

### Hands-on Lab 1 – Policy-Compliant Deployment

**Goal:** Deploy compliant resources

* Reference existing Azure Policy using existing
* Deploy resource with mandatory tags
* Verify successful deployment due to compliance

**Covers:** policies, compliance, enterprise patterns

## Module 6.2 – Capstone Project

### Hands-on Lab 2 – End-to-End Project

**Goal:** Apply everything learned

* Use modular Bicep code
* Deploy network, compute, storage
* Apply tags and naming
* Store code in Azure Repos
* Follow branching workflow
* Deploy via Azure DevOps pipeline
* Validate resources in Azure Portal
* Perform deployment updates through Pull Request workflow
