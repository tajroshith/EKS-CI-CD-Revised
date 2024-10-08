pipeline {

agent any

parameters {
  choice (choices: ['dev', 'qa', 'prod'], description: 'Select the environment', name: 'ENVIRONMENT')
  choice (choices: ['plan', 'apply', 'destroy'], description: 'Terraform action to choose', name: 'action')
}

stages{
    stage('init'){
        steps{
           sh "rm -rf .terraform" 
           sh 'terraform init -no-color -backend-config="${ENVIRONMENT}/${ENVIRONMENT}.tfbackend"'
        }
    }
    stage('format'){
        steps{
           sh "terraform fmt -no-color"
        }
    }
    stage('validate'){
        steps{
           sh "terraform validate -no-color"
        }
    }
    stage('plan'){
        when {
            expression { params.action == "plan" || params.action == "apply" }
        }
        steps{
           sh 'terraform plan -no-color -input=false -out=tfplan -var-file="${ENVIRONMENT}/${ENVIRONMENT}.tfvars"'
        }
    }
    stage('approval'){
        when {
            expression { params.action == "apply"}
        }
        steps{
           sh "terraform show -no-color tfplan > tfplan.txt"
           script { 
                    def plan = readFile "tfplan.txt"               
                    input message: 'Apply the plan?',
                    parameters: [text(defaultValue: plan, description: 'Please review the plan', name: 'Plan')] 
                    }
                }
            }
    stage('apply'){
        when {
            expression { params.action == "apply" }
        }
        steps{
            sh "terraform apply -no-color -input=false tfplan"
        }
    }
    stage('preview-destroy'){
         when {
            expression { params.action == "destroy"}
        }
        steps{
            sh 'terraform plan -no-color -input=false -destroy -out=tfplan -var-file="${ENVIRONMENT}/${ENVIRONMENT}.tfvars"'
            sh "terraform show -no-color tfplan > tfplan.txt"
        }
    }
    stage('destroy'){
        when {
            expression { params.action == "destroy"}
        }
        steps{
            script {
              def plan = readFile "tfplan.txt"
              input message: 'Delete the resources?',
              parameters: [text(defaultValue: plan, description: 'Please review the plan', name: 'Plan')] 
            }
            sh "terraform destroy -no-color -input=false --auto-approve"
        }
     }
   }
}
