{{/*
Expand the name of the chart.
*/}}
{{- define "rolloutdemo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rolloutdemo.fullname" -}}
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
{{- define "rolloutdemo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rolloutdemo.labels" -}}
helm.sh/chart: {{ include "rolloutdemo.chart" . }}
{{ include "rolloutdemo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rolloutdemo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rolloutdemo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "rolloutdemo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rolloutdemo.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Dynamically compute Route Host for for preview
*/}}
{{- define "rolloutdemo.previewRouteHost" -}}
{{ printf "%s-preview-route-%s.%s" (include "rolloutdemo.fullname" .) .Release.Namespace .Values.clusterDomain }}
{{- end }}


{{/*
Active route host
*/}}
{{- define "rolloutdemo.activeRouteHost" -}}
{{ printf "%s-route-%s.%s" (include "rolloutdemo.fullname" .) .Release.Namespace .Values.clusterDomain }}
{{- end }}
