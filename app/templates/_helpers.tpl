{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "app.fullname" -}}
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
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
helm.sh/chart: {{ include "app.chart" . }}
{{ include "app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Pod template spec — shared between Deployment and StatefulSet.
Includes everything inside spec.template.
*/}}
{{- define "app.podTemplate" -}}
metadata:
  {{- with .Values.podAnnotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "app.labels" . | nindent 4 }}
    {{- with .Values.podLabels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  {{- with .Values.imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  serviceAccountName: {{ include "app.serviceAccountName" . }}
  {{- with .Values.podSecurityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.initContainers }}
  initContainers:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  containers:
    - name: {{ .Chart.Name }}
      {{- with .Values.securityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      {{- with .Values.container.command }}
      command:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.container.args }}
      args:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.container.ports }}
      ports:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.container.env }}
      env:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if .Values.healthChecks.liveness.enabled }}
      livenessProbe:
        {{- if eq .Values.healthChecks.liveness.type "httpGet" }}
        httpGet:
          {{- toYaml .Values.healthChecks.liveness.httpGet | nindent 10 }}
        {{- else if eq .Values.healthChecks.liveness.type "tcpSocket" }}
        tcpSocket:
          {{- toYaml .Values.healthChecks.liveness.tcpSocket | nindent 10 }}
        {{- else if eq .Values.healthChecks.liveness.type "exec" }}
        exec:
          {{- toYaml .Values.healthChecks.liveness.exec | nindent 10 }}
        {{- end }}
        initialDelaySeconds: {{ .Values.healthChecks.liveness.initialDelaySeconds }}
        periodSeconds: {{ .Values.healthChecks.liveness.periodSeconds }}
        timeoutSeconds: {{ .Values.healthChecks.liveness.timeoutSeconds }}
        failureThreshold: {{ .Values.healthChecks.liveness.failureThreshold }}
      {{- end }}
      {{- if .Values.healthChecks.readiness.enabled }}
      readinessProbe:
        {{- if eq .Values.healthChecks.readiness.type "httpGet" }}
        httpGet:
          {{- toYaml .Values.healthChecks.readiness.httpGet | nindent 10 }}
        {{- else if eq .Values.healthChecks.readiness.type "tcpSocket" }}
        tcpSocket:
          {{- toYaml .Values.healthChecks.readiness.tcpSocket | nindent 10 }}
        {{- else if eq .Values.healthChecks.readiness.type "exec" }}
        exec:
          {{- toYaml .Values.healthChecks.readiness.exec | nindent 10 }}
        {{- end }}
        initialDelaySeconds: {{ .Values.healthChecks.readiness.initialDelaySeconds }}
        periodSeconds: {{ .Values.healthChecks.readiness.periodSeconds }}
        timeoutSeconds: {{ .Values.healthChecks.readiness.timeoutSeconds }}
        failureThreshold: {{ .Values.healthChecks.readiness.failureThreshold }}
      {{- end }}
      {{- with .Values.resources }}
      resources:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if or .Values.volumeMounts (and .Values.persistence.enabled .Values.persistence.volumes) }}
      volumeMounts:
        {{- with .Values.volumeMounts }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- if .Values.persistence.enabled }}
        {{- range .Values.persistence.volumes }}
        - name: {{ .name }}
          mountPath: {{ .mountPath }}
        {{- end }}
        {{- end }}
      {{- end }}
    {{- with .Values.sidecars }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .Values.volumes }}
  volumes:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.nodeSelector }}
  nodeSelector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.affinity }}
  affinity:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
