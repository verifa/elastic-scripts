@echo off
curl -k --user %ELASTIC_USER%:%ELASTIC_PASSWORD% https://%EP%/_cat/health?v