function redirect(path) {
  return {
    statusCode: 302,
    headers: {
      'location': { value: path }
    }
  }
}

function handler(event) {
  if (event.response.statusCode != 404) {
    // We'll only handle some 404 errors
    return event.response
  }

  var requestPath = event.request.uri

  if(requestPath == '/api' || requestPath == '/api/') {
    return redirect('/api/${CRYSTAL_VERSION}/')
  }

  if(requestPath.startsWith('/api/latest/')) {
    return redirect(requestPath.replace('/api/latest/', '/api/${CRYSTAL_VERSION}/'))
  } else if(requestPath.startsWith('/api/') && !(requestPath.startsWith('/api/0') || requestPath.startsWith('/api/1') || requestPath.startsWith('/api/master/'))) {
    return redirect(requestPath.replace('/api/', '/api/${CRYSTAL_VERSION}/'))
  }

  return event.response
}
