function handler(event) {
    var requestPath = event.request.uri
    var redirectUri = null

    if(requestPath.startsWith('/api/latest/')) {
      redirectUri = requestPath.replace('/api/latest/', '/api/${CRYSTAL_VERSION}/')
    } else if(requestPath.startsWith('/api/') && !(requestPath.startsWith('/api/0') || requestPath.startsWith('/api/1'))) {
      redirectUri = requestPath.replace('/api/', '/api/${CRYSTAL_VERSION}/')
    }

    if(redirectUri != null) {
      return {
        statusCode: 302,
        headers: {
          'location': { value: redirectUri }
        }
      }
    }

    return event.request
}
