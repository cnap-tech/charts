{{/*
Common labels
*/}}
{{- define "codezero.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "codezero.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Full image reference for Code Zero components
*/}}
{{- define "codezero.image" -}}
{{ .Values.image.registry }}/{{ .component }}:{{ .Values.image.tag }}{{ if .edition }}-{{ .edition }}{{ end }}
{{- end }}

{{/*
Sagittarius image (includes edition suffix)
*/}}
{{- define "codezero.sagittariusImage" -}}
{{ .Values.image.registry }}/sagittarius:{{ .Values.image.tag }}-{{ .Values.image.edition }}
{{- end }}

{{/*
Sculptor image (includes edition suffix)
*/}}
{{- define "codezero.sculptorImage" -}}
{{ .Values.image.registry }}/sculptor:{{ .Values.image.tag }}-{{ .Values.image.edition }}
{{- end }}

{{/*
Component image (no edition suffix)
*/}}
{{- define "codezero.componentImage" -}}
{{ .Values.image.registry }}/{{ .component }}:{{ .Values.image.tag }}
{{- end }}

{{/*
Draco image with variant suffix
*/}}
{{- define "codezero.dracoImage" -}}
{{ .Values.image.registry }}/draco:{{ .Values.image.tag }}-{{ .variant }}
{{- end }}

{{/*
Service account name
*/}}
{{- define "codezero.serviceAccountName" -}}
{{- if .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name }}
{{- else }}
{{- .Release.Name }}-codezero
{{- end }}
{{- end }}

{{/*
Config volume name
*/}}
{{- define "codezero.configVolume" -}}
{{ .Release.Name }}-generated-configs
{{- end }}

{{/*
Postgres connection details
*/}}
{{- define "codezero.postgresHost" -}}
{{ .Release.Name }}-postgres
{{- end }}
