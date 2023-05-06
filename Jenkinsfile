pipeline{

    parameters {
        booleanParam(name: 'autoApprove', defaulValue: false, description: 'Automatically run apply after generating plan')
    }
    environment {
        AWS_ACCEESS_KEY_ID      = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY   = credentials('AWS_SECRET_ACCESS_KEY')
    }

    agent any 
    stages {
        stage ('checkout') {
            steps {
                script{
                    dir("terraform-projects")
                    {
                        git "https://github.com/youngmind01/Terraform-projects.git"
                    }
                }
            }
        }
        
        stage('Plan'){
            steps{
                sh 'pwd;cd terraform-projects/ ; terraform init'
                sh 'pwd;cd terraform-projects/ ; terraform plan -out tfplan'
                sh 'pwd;cd terraform-projects/ ; terraform -no-color tfplan > tfplan,txt'
            }
        }

        stage('Approval'){
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }
            steps{
                script{
                    def plan = readFile 'terraform-projects/tfplan.txt'
                    input message: "Do you want to apply the plan",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaulValue: plan)]
                }
            }
        }

        stage('Apply'){
            steps {
                sh "pwd;cd terraform-projects/ ; terraform apply -input=false tfplan"
            }
        }

    }
}