{{- define "name" -}}
{{- default (printf "%s-%s" .Values.namespace .Values.name) .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
