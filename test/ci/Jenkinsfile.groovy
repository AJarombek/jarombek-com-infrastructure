/**
 * Jenkinsfile which executes when the trigger job is built.
 * @author Andrew Jarombek
 * @since 6/2/2019
 */

node("master") {
    stage('jarombek-com-infrastructure') {
        build job: 'jarombek-com-infrastructure/jarombek-com-infrastructure-dev', parameters: [
            [$class: 'StringParameterValue', name: 'branchName', value: 'master']
        ]
        build job: 'jarombek-com-infrastructure/jarombek-com-infrastructure-prod', parameters: [
            [$class: 'StringParameterValue', name: 'branchName', value: 'master']
        ]
    }
}