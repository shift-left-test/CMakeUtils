@Library('jenkins-shared-library') _

pipeline {
    agent {
	docker {
	    image "${getDockerImage('python-dev:latest')}"
	}
    }
    stages {
	stage("Test") {
	    steps {
		sh "python3 -m pytest -xvv --junitxml result.xml"
	    }
	}
	stage("Report") {
	    steps {
		junit "result.xml"
	    }
	}
    }  // stages
}  // pipeline
