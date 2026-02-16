{{/* Auth provider metadata for config and secret generation. */}}
{{- define "openclaw.authMap" -}}
anthropic:
  profileId: "anthropic:default"
  secretKey: anthropicApiKey
  envVar: ANTHROPIC_API_KEY
openai:
  profileId: "openai:default"
  secretKey: openaiApiKey
  envVar: OPENAI_API_KEY
openrouter:
  profileId: "openrouter:default"
  secretKey: openrouterApiKey
  envVar: OPENROUTER_API_KEY
gemini:
  profileId: "gemini:default"
  secretKey: geminiApiKey
  envVar: GEMINI_API_KEY
{{- end -}}
