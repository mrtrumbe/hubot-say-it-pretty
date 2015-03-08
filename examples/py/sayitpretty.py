import json
import urllib
import urllib2

class SayItPretty(object):
    def __init__(self, url):
        self.url = url

    def _request(self, command):
        result = None
        req = urllib2.Request(self.url, 
                              json.dumps(command), 
                              {'Content-Type': 'application/json'}
                             )
        try:
            res = urllib2.urlopen(req)
            result = res.read()
        except urllib2.HTTPError, error:
            msg = error.read()
            raise Exception("API Error: " + msg)
        return result

    def say_text(self, room, text):
        return self._request({'room': room, 'text': text});

    def say_it(self, room, title=None, head=None, message=None, 
               indent=None, compact=None):
        command = {'room': room}
        if title is not None:
            command['title'] = title

        if head is not None:
            command['head'] = head

        if message is not None:
            command['message'] = message

        if indent is not None:
            command['indent'] = indent

        if compact is not None:
            command['compact'] = compact

        return self._request(command);

