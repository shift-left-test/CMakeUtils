pipeline {
    agent {
	docker {
	    image "cart.lge.com/swte/yocto-dev:18.04"
	}
    }
    stages {
	stage("Setup") {
	    steps {
		updateGitlabCommitStatus name: "jenkins", state: "running"
	    }
	}  // stage
	stage("Test") {
	    steps {
                cleanWs disableDeferredWipeout: true
                git branch: "${env.gitlabSourceBranch}", url: "http://mod.lge.com/hub/yocto/addons/CMakeUtils.git"
		sh "pytest -xvv --junitxml result.xml"
	    }
	}  // stage
	stage("Report") {
	    steps {
		junit "result.xml"
	    }
	}  // stage
    }  // stages
    post {
        success {
            updateGitlabCommitStatus name: "jenkins", state: "success"
        }
        failure {
            updateGitlabCommitStatus name: "jenkins", state: "failed"
        }
    }
}  // pipeline
