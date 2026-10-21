
pipeline {
    agent any

    stages {
        stage('Test EKS Connection') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'kubeconfig-file',
                        variable: 'KUBECONFIG'
                    )
                ]) {
                    sh '''
                        set -e
                        echo "Checking AWS identity..."
                        aws sts get-caller-identity

                        echo "Checking EKS nodes..."
                        kubectl get nodes

                        echo "Checking webapps namespace..."
                        kubectl get pods -n webapps
                    '''
                }
            }
        }

        stage('Deploy To Kubernetes') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'eks-kubeconfig-file',
                        variable: 'KUBECONFIG'
                    )
                ]) {
                    sh '''
                        set -e
                        kubectl apply -f deployment-service.yml -n webapps
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'eks-kubeconfig-file',
                        variable: 'KUBECONFIG'
                    )
                ]) {
                    sh '''
                        set -e
                        kubectl get deployments -n webapps
                        kubectl get pods -n webapps
                        kubectl get svc -n webapps
                    '''
                }
            }
        }
    }
}
