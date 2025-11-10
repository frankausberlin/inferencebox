# Docker Image Optimization Plan

## Current State Analysis

The project currently has three Dockerfiles:
1. `Dockerfile` - Main Dockerfile
2. `Dockerfile.vastai` - Vast.ai specific Dockerfile
3. `Dockerfile.vastai.optimized` - Optimized version for Vast.ai

This creates redundancy and maintenance overhead.

## Cache and Temporary File Cleanup

### Open WebUI Cache
The Open WebUI cache directory contains large model files that take up significant storage space:
- `cache/embedding/models/models--sentence-transformers--all-MiniLM-L6-v2/`
- Other model cache directories

### Recommendations
1. Implement cache cleanup policies
2. Add documentation on cache management
3. Consider volume management strategies for large model files

## Dockerfile Optimization

### Current Issues
1. Redundant Dockerfiles
2. Potential for better layer optimization
3. Cache cleanup could be improved

### Recommendations

#### 1. Consolidate Dockerfiles
- Use build arguments to create a single Dockerfile that can handle different scenarios
- Remove redundant Dockerfiles
- Ensure clear documentation on which build arguments to use for which scenario

#### 2. Layer Optimization
- Combine related RUN commands to reduce layer count
- Install frequently used packages first to leverage Docker layer caching
- Separate package installation from code copying to maximize cache hits
- Use multi-stage builds to separate build dependencies from runtime dependencies

#### 3. Cache Management
- Ensure all temporary files and caches are properly cleaned in each layer
- Use pip's cache directory effectively
- Mount cache directories as volumes for persistent caching across container restarts
- Clean up cache directories periodically to save space

## Implementation Plan

### Phase 1: Documentation and Planning
1. Create this optimization plan
2. Document current image sizes
3. Identify optimization opportunities

### Phase 2: Dockerfile Consolidation
1. Create a unified Dockerfile using build arguments
2. Test the new Dockerfile with different configurations
3. Update documentation to reflect the changes
4. Remove redundant Dockerfiles

### Phase 3: Layer Optimization
1. Optimize RUN commands
2. Reorder installation steps for better caching
3. Implement multi-stage builds where appropriate
4. Test image sizes and build times

### Phase 4: Cache Management
1. Implement cache cleanup policies
2. Add documentation on cache management
3. Test the changes to ensure they work correctly

## Expected Benefits

1. Reduced image size
2. Faster build times
3. Easier maintenance
4. Better cache utilization
5. More consistent deployment process