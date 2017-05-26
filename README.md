# Quizzer on Kubernetes
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/4fd608e05ba54914bba2467296223799)](https://www.codacy.com/app/nmuzychuk/quizzer-kubernetes)

## Overview
Kubernetes deployment files for [quizzer](https://github.com/nmuzychuk/quizzer) web app.

## Test
Integration test builds single-machine Kubernetes cluster.

```console
vagrant up
vagrant ssh
cd /vagrant

sudo bash test.sh
```

## License
This project is released under the [MIT License](LICENSE)
