{{/*
Expand the name of the chart.
*/}}
{{- define "storage-local-path.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "storage-local-path.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "storage-local-path.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "storage-local-path.labels" -}}
helm.sh/chart: {{ include "storage-local-path.chart" . }}
{{ include "storage-local-path.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "storage-local-path.selectorLabels" -}}
app.kubernetes.io/name: {{ include "storage-local-path.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Namespace - always uses release namespace
*/}}
{{- define "storage-local-path.namespace" -}}
{{- .Release.Namespace }}
{{- end }}

{{/*
Provisioner image
*/}}
{{- define "storage-local-path.provisionerImage" -}}
{{- printf "%s:%s" .Values.provisioner.image.repository (.Values.provisioner.image.tag | default .Chart.AppVersion) }}
{{- end }}
