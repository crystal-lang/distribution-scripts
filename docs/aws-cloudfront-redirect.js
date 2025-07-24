function redirect(path) {
  return {
    statusCode: 302,
    headers: {
      'location': { value: path }
    }
  }
}

const LATEST_INDEX_REDIRECTION_PATHS = [ '/api', '/api/', '/api/index.html', '/api/latest']

function handler(event) {
  if (event.response.statusCode != 404) {
    // We'll only handle some 404 errors
    return event.response
  }

  var requestPath = event.request.uri

  if(LATEST_INDEX_REDIRECTION_PATHS.includes(requestPath)) {
    return redirect('/api/${CRYSTAL_VERSION}/')
  }

  if(requestPath.startsWith('/api/latest/')) {
    return redirect(requestPath.replace('/api/latest/', '/api/${CRYSTAL_VERSION}/'))
  } else if(requestPath.startsWith('/api/') && !(requestPath.startsWith('/api/0') || requestPath.startsWith('/api/1') || requestPath.startsWith('/api/master/'))) {
    return redirect(requestPath.replace('/api/', '/api/${CRYSTAL_VERSION}/'))
  }

  return event.response
}
