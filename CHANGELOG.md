# Changelog

## [Unreleased]

### Changed
- Aktualisiert das Basisimage im Dockerfile von `nvidia/cuda:12.4.1-runtime-ubuntu22.04` auf `nvidia/cuda:12.6.3-devel-ubuntu22.04` für verbesserte Vast.ai-Kompatibilität
- Aktualisiert die Docker Compose-Konfiguration:
  - Ändert `OLLAMA_BASE_URL` im Open WebUI Service von `http://datascience-env:11435` zu `http://ollama:11435`
  - Ändert die Abhängigkeit des Open WebUI Service von `datascience-env` zu `ollama`
  - Erhöht `start_period` für Health Checks von 30s auf 60s für bessere Stabilität in Vast.ai-Umgebung
  - Erhöht `start_period` für den datascience-env Service von 40s auf 60s

### Fixed
- Korrigiert die Service-Abhängigkeiten in der Docker Compose-Konfiguration für zuverlässige Startreihenfolge
- Optimiert Health Checks für verbesserte Stabilität in Vast.ai-Umgebung

## [1.0.0] - 2025-11-10

### Added
- Initiale Version des inferencebox-Projekts
- Multi-Container-Anwendung mit Jupyter, Ollama und Open WebUI
- Unterstützung für GPU-Beschleunigung mit NVIDIA CUDA
- Docker Compose-Konfiguration für einfache Bereitstellung
- Umfassende Dokumentation einschließlich Vast.ai-Bereitstellungsanleitung