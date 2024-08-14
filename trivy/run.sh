#!/bin/bash
trivy image yohrannes/website-portifolio > trivy-scan.txt
cat trivy-scan.txt
