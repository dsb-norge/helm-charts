{{/*
Helper to envify config maps like dsb-nginx-frontend */}}
{{- define "envify" -}}
{{- $prefix := index . 0 -}}
{{- $value := index . 1 -}}
{{- if kindIs "map" $value -}}
  {{- range $k, $v := $value -}}
    {{- if $prefix -}}
        {{- template "envify" (list (printf "%s.%s" $prefix $k) $v) -}}
    {{- else -}}
        {{- template "envify" (list (printf "%s" $k) $v) -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
    {{ $prefix | indent 2 }}: {{ $value | quote }}
{{ end -}}
{{- end -}}
