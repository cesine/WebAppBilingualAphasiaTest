var fs         = require('fs'),
    exec       = require('child_process').exec,
    sys        = require('sys'),
    path       = require('path'),
    http       = require('http'),
    formidable = require('./lib/formidable'),
    paperboy   = require('./lib/paperboy');

var PUBLIC = path.join(path.dirname(__filename), 'public');
var devmode = false;
var port = 8136;
if (devmode){
  port = 8134;
}
var statuses = {};
var progresses = {};
var metadata   = {};

var child;

function puts(error, stdout, stderr) { sys.puts(stdout) };
function logsAndFlagsFresh(error,uuid,stdout,stderr){
  sys.puts(stdout);
  var setFresh = function(){
    statuses[uuid]="transcription fresh";
    sys.print("\nProcessed uuid: "+uuid+" set to: "+statuses[uuid]+"\n\n");
  }
  return setFresh;
};


http.createServer(function(req, res) {
  /*TODO check for API key and non banned install id in this regex */
  regex = new RegExp('/upload/(.+)');
  match = regex.exec(req.url);
  if (match && req.method.toLowerCase() == 'post') {
    var uuid = match[1];
		uuid = uuid.replace(/.3gp/,"");
    uuid = uuid.replace(/.mp3/,"");
    uuid = uuid.replace(/.srt/,"");
    uuid = uuid.replace(/_client/,"");
    uuid = uuid.replace(/_server/,"");
    sys.print("Receiving transcription request: "+uuid+'\n');
    
    var form = new formidable.IncomingForm();
    form.uploadDir = './data';
    form.keepExtensions = true;

    // keep track of progress.
    form.addListener('progress', function(recvd, expected) {
      progress = (recvd / expected * 100).toFixed(2);
      progresses[uuid] = progress;
    });

    form.parse(req, function(error, fields, files) {
      var path     = files['file']['path'],
          filename = files['file']['filename'],
          mime     = files['file']['mime'];
      sys.print('Users file: '+filename + ':filename\nIs server file: ' + path +  ':path\n');

      /*
       * Rename to original name (sanitize, although it shoudl already be sanitized by the android client.)
       */
      var safeFilename=filename.replace(/[^\w\.]/g,"_");
      safeFilename=safeFilename.replace(/[;:|@&*/\\]/g,"_");
      //safeFilename=safeFilename.replace(/_client\./,".");
      safeFilename=safeFilename.replace(/\.mp3/,".amr");
      var tempdir = "../backup/";
      fs.renameSync(path,tempdir+safeFilename);
      safeFilenameServer = safeFilename.replace(/_client/,"_server");
      
      var videoregex = new RegExp('(.+).3gp');
      var matchvideo = videoregex.exec(filename);
      res.writeHead(200, {'content-type': 'text/html'});
      if(matchvideo){
        res.write("Server is Processing.\n");
        res.write(filename + ':filename\n' + path + ':path\n');
        //TODO run versioning on all uploaded files
				exec("bash audio2text.sh "+ safeFilename.replace(/\.3gp/,""),puts);
      }else{
				res.write("File uploaded.");
			}
			res.end();
      exec("date",puts);
      sys.print("\tFinished upload processing."+'\n');
    });
    
    return;
  }

  // (update) metadata
  regex = new RegExp('/update/(.+)');
  match = regex.exec(req.url);
  if (match && req.method.toLowerCase() == 'post') {
    uuid = match[1];
    var form = new formidable.IncomingForm();
    form.addListener('field', function(name, value) {
      sys.print("fresh metadata for "+uuid+": "+name+" => "+value+"\n")
      metadata[name] = value;
    });
    form.parse(req);
  }
	// respond to status queries
  regex = new RegExp('/extract/(.+)');
  match = regex.exec(req.url);
  if (match) {
    uuid = match[1];
    uuid = uuid.replace(/.mp3/,"");
		res.writeHead(200, {'content-type': 'text/html'});
		res.write("<html>");

		regex = new RegExp('/extract/touch');
	  match = regex.exec(req.url);
		if(match){	
	    res.write("Extracting touch results from the subtitles....<p>&nbsp</p>The data is now integrated in the <a href='/touch_response_visualizer.html'>touch response visualizer</a>");
			exec("bash ../backup/srt2touchdatadir.sh ",puts);
  	}else{
			res.write("Extracting textgrids using Praat. This may take a while....");
			exec("bash praatfiles/audio2textGrid.sh ",puts);
		}
		res.write("<p>The raw results are in the <a href='file:///Applications/OPrimeAdministrator.app/Contents/Resources/oprime-server/results'>/Applications/OPrimeAdministrator.app/Contents/Resources/oprime-server/results</a> ");
	  res.end();

	}
  // respond to status queries
  regex = new RegExp('/status/(.+)');
  match = regex.exec(req.url);
  if (match) {
    uuid = match[1];
    uuid = uuid.replace(/.mp3/,"");
    uuid = uuid.replace(/.srt/,"");
    uuid = uuid.replace(/_client/,"");
    uuid = uuid.replace(/_server/,"");

    res.writeHead(200, {'content-type': 'application/json'});
    res.write(JSON.stringify({'status': statuses[uuid]}));
    res.end();
    
    exec("date",puts);
    sys.print(uuid+"\nReplied to status request: "+JSON.stringify({'status': statuses[uuid]}));
    sys.print("\n\n");
  }

  // respond to progress queries.
  regex = new RegExp('/progress/(.+)');
  match = regex.exec(req.url);
  if (match) {
    uuid = match[1];
    res.writeHead(200, {'content-type': 'application/json'});
    res.write(JSON.stringify({'progress': progresses[uuid]}));
    res.end();
  }

  // let paperboy handle any static content.
  paperboy
    .deliver(PUBLIC, req, res)
    .after(function(statCode) {
      sys.log('Served Request: ' + statCode + ' ' + req.url)
    })
    .otherwise(function() {
      res.writeHead(404, {'Content-Type': 'text/plain'});
      res.write('Not Found');
      res.end();
    });

}).listen(port);

sys.log('ready at http://localhost:'+port+'/')
