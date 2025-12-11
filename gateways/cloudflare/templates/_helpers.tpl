{{/*
Expand the name of the chart.
*/}}
{{- define "gateway-cloudflare.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "gateway-cloudflare.fullname" -}}
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
Common labels
*/}}
{{- define "gateway-cloudflare.labels" -}}
helm.sh/chart: {{ include "gateway-cloudflare.chart" . }}
{{ include "gateway-cloudflare.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gateway-cloudflare.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gateway-cloudflare.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Chart label
*/}}
{{- define "gateway-cloudflare.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Controller namespace
*/}}
{{- define "gateway-cloudflare.controllerNamespace" -}}
{{- .Values.controller.namespace | default "cloudflare-gateway" }}
{{- end }}

{{/*
Gateway namespace
*/}}
{{- define "gateway-cloudflare.gatewayNamespace" -}}
{{- .Values.gateway.namespace | default .Release.Namespace }}
{{- end }}

{{/*
Secret name for Cloudflare credentials
*/}}
{{- define "gateway-cloudflare.secretName" -}}
{{- if .Values.cloudflare.existingSecret }}
{{- .Values.cloudflare.existingSecret }}
{{- else }}
{{- printf "%s-cloudflare" (include "gateway-cloudflare.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Service account name
*/}}
{{- define "gateway-cloudflare.serviceAccountName" -}}
{{- if .Values.controller.serviceAccount.name }}
{{- .Values.controller.serviceAccount.name }}
{{- else }}
{{- include "gateway-cloudflare.fullname" . }}
{{- end }}
{{- end }}

{{/*
Controller image
*/}}
{{- define "gateway-cloudflare.controllerImage" -}}
{{- $tag := .Values.controller.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.controller.image.repository $tag }}
{{- end }}

