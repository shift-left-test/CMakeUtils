pipeline {
    agent {
	docker {
	    image "cart.lge.com/swte/ubuntu-dev:latest"
	}
    }
    stages {
	stage("Test") {
	    steps {
		sh "pytest -xvv --junitxml result.xml"
	    }
	}
	stage("Report") {
	    steps {
		junit "result.xml"
	    }
	}
    }  // stages
}  // pipeline
