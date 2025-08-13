// Since CloudFront doesn't run functions when the origin returns a statusCode >=400
// this function has to run upon "viewer request", before hitting the origin

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
  var requestPath = event.request.uri

  // well-known paths that should be queried as-is
  if(
    requestPath == '/api/versions.json' ||
    requestPath.startsWith('/api/1.') ||
    requestPath.startsWith('/api/0.') ||
    requestPath == '/api/master' ||
    requestPath.startsWith('/api/master/')
  ) {
    return event.request
  }

  // prefixes that go to the current version's index
  if(LATEST_INDEX_REDIRECTION_PATHS.includes(requestPath)) {
    return redirect('/api/${CRYSTAL_VERSION}/')
  }

  // "latest" prefix should be re-written to the current version
  if(requestPath.startsWith('/api/latest/')) {
    return redirect(requestPath.replace('/api/latest/', '/api/${CRYSTAL_VERSION}/'))
  }

  // at this point, we assume the request omited the version - eg, `/api/String.html`
  return redirect(requestPath.replace('/api/', '/api/${CRYSTAL_VERSION}/'))
}
