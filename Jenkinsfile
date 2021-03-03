pipeline {
    agent {
	docker {
	    image "cart.lge.com/swte/yocto-dev:18.04"
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
