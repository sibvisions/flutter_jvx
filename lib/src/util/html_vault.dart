import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class HtmlVault {

  /// iterations
  static final int _iterations = 800000;
  /// bits
  static final int _bits = 256;

  ///Creates a secure html document with [password] encrypted [htmlContent] and enter password dialog.
  static Future<String> create({
    required String htmlContent,
    required String password,
    String? template
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _iterations,
      bits: _bits,
    );

    // salt for key creation (16 Bytes)
    final salt = Uint8List.fromList(List.generate(16, (_) => Random().nextInt(_bits)));

    // derive AES key from password
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );

    // encrypt with AES-GCM
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce(); // initialization vector
    final secretBox = await algorithm.encrypt(
      utf8.encode(htmlContent),
      secretKey: secretKey,
      nonce: nonce,
    );

    // base64 encoding :)
    final payloadB64 = base64.encode(secretBox.cipherText);
    // ... auth-tag
    final macB64 = base64.encode(secretBox.mac.bytes);
    final nonceB64 = base64.encode(nonce);
    final saltB64 = base64.encode(salt);

    return _assembleHtml(template, payloadB64, macB64, nonceB64, saltB64);
  }

  static String _assembleHtml(String? template, String data, String mac, String iv, String salt) {
    if (template != null) {
      return template.replaceAll("\$salt", salt)
        .replaceAll("\$iv", iv)
        .replaceAll("\$mac", mac)
        .replaceAll("\$data", data)
        .replaceAll("\$_bits", "$_bits")
        .replaceAll("\$_iterations", "$_iterations");
    }
    else {
//Original script
/*
    // We don't use onkeypress because it's deprecated, so use event listener for "Enter" key
    document.getElementById('passwordInput').addEventListener('keydown', function(event) {
        if (event.key === 'Enter') {
            unlock();
        }
    });

    async function unlock() {
        const password = document.getElementById('passwordInput').value;
        const b64ToBuf = (b) => Uint8Array.from(atob(b), c => c.charCodeAt(0));

        try {
            const salt = b64ToBuf("$salt");
            const iv = b64ToBuf("$iv");
            const mac = b64ToBuf("$mac");
            const encrypted = b64ToBuf("$data");

            // password to key
            const enc = new TextEncoder();
            const baseKey = await crypto.subtle.importKey("raw", enc.encode(password), "PBKDF2", false, ["deriveKey"]);

            // derive AES-GCM key
            const aesKey = await crypto.subtle.deriveKey(
                { name: "PBKDF2", salt: salt, iterations: $_iterations, hash: "SHA-256" },
                baseKey,
                { name: "AES-GCM", length: $_bits },
                false, ["decrypt"]
            );

            // merge data and mac (webCrypto API standard)
            const combined = new Uint8Array(encrypted.length + mac.length);
            combined.set(encrypted);
            combined.set(mac, encrypted.length);

            // decrypt
            const decrypted = await crypto.subtle.decrypt(
                { name: "AES-GCM", iv: iv, tagLength: 128 },
                aesKey,
                combined
            );

            // show decrypted content in "viewer"
            document.getElementById('auth-ui').style.display = 'none';
            const v = document.getElementById('viewer');
            v.innerHTML = new TextDecoder().decode(decrypted);
            v.style.display = 'block';

            document.body.classList.add('viewer-active');
        } catch (e) {
            alert("Wrong password.");
        }
    }
*/
      //see test/html/minify_script.dart
      String script = "const a0_0x4f1dc3=a0_0x1d97;(function(_0x350bbf,_0xba994e){const _0x5dd7f1=a0_0x1d97,_0x21411c=_0x350bbf();while(!![]){try{const _0x1f2d0a=-parseInt(_0x5dd7f1(0xa0))/(0xd43+-0xb8+0xd6*-0xf)*(parseInt(_0x5dd7f1(0x7e))/(0x1*0xdff+0x10b5+-0x1eb2*0x1))+-parseInt(_0x5dd7f1(0xa3))/(0x26*-0xc5+-0x54*-0x51+0x2ad*0x1)+-parseInt(_0x5dd7f1(0x8e))/(-0x197c*0x1+-0x51*-0x75+-0xb85)+parseInt(_0x5dd7f1(0x7b))/(0x5*-0x17+0x1*0x1232+-0x11ba*0x1)+parseInt(_0x5dd7f1(0x93))/(0x2e5+0x11*-0x109+-0x179*-0xa)+-parseInt(_0x5dd7f1(0x90))/(0x7*-0x10d+-0xb4*0x25+0x2166)*(parseInt(_0x5dd7f1(0x9b))/(-0x48f*0x5+-0x216e+0x3841*0x1))+parseInt(_0x5dd7f1(0x7a))/(0x1376+0x3*-0x156+-0x1*0xf6b);if(_0x1f2d0a===_0xba994e)break;else _0x21411c['push'](_0x21411c['shift']());}catch(_0x3f7b56){_0x21411c['push'](_0x21411c['shift']());}}}(a0_0x29d1,-0x46ba*0x18+-0xc51b*-0x13+0x52d6e),document[a0_0x4f1dc3(0xa1)](a0_0x4f1dc3(0x82))[a0_0x4f1dc3(0x9c)](a0_0x4f1dc3(0x87),function(_0x513afa){const _0x31a1f4=a0_0x4f1dc3,_0x51a339={'xOjvO':function(_0x223267,_0x579387){return _0x223267===_0x579387;},'CZBWd':'Enter','GXsCv':function(_0x5d8e27){return _0x5d8e27();}};_0x51a339[_0x31a1f4(0x83)](_0x513afa['key'],_0x51a339[_0x31a1f4(0x75)])&&_0x51a339[_0x31a1f4(0x96)](unlock);}));function a0_0x1d97(_0x7a7903,_0x27abe4){_0x7a7903=_0x7a7903-(-0x2a4+0x17f+0x199);const _0x342e07=a0_0x29d1();let _0x1d2821=_0x342e07[_0x7a7903];if(a0_0x1d97['TPvHll']===undefined){var _0x3062aa=function(_0x1aa027){const _0x202c9e='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/=';let _0xe3c9d2='',_0x378e17='';for(let _0x47289e=-0x7*0x581+0x2051+-0x9f*-0xa,_0x166484,_0x2313ae,_0xd9ab82=0x2*-0x5e2+-0xd6c+-0x10*-0x193;_0x2313ae=_0x1aa027['charAt'](_0xd9ab82++);~_0x2313ae&&(_0x166484=_0x47289e%(-0x2b6*0x8+-0x32d+0xc1*0x21)?_0x166484*(0x1*0x18bc+-0x1d6*-0x2+-0x1c28)+_0x2313ae:_0x2313ae,_0x47289e++%(-0xf*-0x9b+-0x3*-0x37d+-0x1388))?_0xe3c9d2+=String['fromCharCode'](0x1e3a+-0x1702*0x1+-0x639&_0x166484>>(-(0x1b80+-0x22f2+0x774)*_0x47289e&0x1*0x407+-0x416*0x4+0xc57)):0xc6b+-0x1061+-0x3f6*-0x1){_0x2313ae=_0x202c9e['indexOf'](_0x2313ae);}for(let _0xc1de8=-0xe*-0x55+0x1cfe+-0x21a4,_0x4a3f2b=_0xe3c9d2['length'];_0xc1de8<_0x4a3f2b;_0xc1de8++){_0x378e17+='%'+('00'+_0xe3c9d2['charCodeAt'](_0xc1de8)['toString'](-0x15c5*-0x1+0x101d+-0x25d2))['slice'](-(0x5aa*-0x5+-0x1e0a+-0x1*-0x3a5e));}return decodeURIComponent(_0x378e17);};a0_0x1d97['LMXULl']=_0x3062aa,a0_0x1d97['gShnZu']={},a0_0x1d97['TPvHll']=!![];}const _0xdb3f98=_0x342e07[0x31*-0x53+0x1997+-0x9b4],_0x42ca02=_0x7a7903+_0xdb3f98,_0x3c8b33=a0_0x1d97['gShnZu'][_0x42ca02];return!_0x3c8b33?(_0x1d2821=a0_0x1d97['LMXULl'](_0x1d2821),a0_0x1d97['gShnZu'][_0x42ca02]=_0x1d2821):_0x1d2821=_0x3c8b33,_0x1d2821;}function a0_0x29d1(){const _0x1d828c=['sxbHD1O','y2HHCKnVzgvbDa','zxvLDKm','CgfZC3DVCMrjBNb1Da','Ee9QDK8','sgzPCMG','rNH4z0C','zNjVBq','A2v5zg93BG','zgvJCNLWDa','v3jVBMCGCgfZC3DVCMqU','uNrgDKq','DMLLD2vYlwfJDgL2zq','DM5Jswy','C3r5Bgu','ndC0mJuYngzuAKL6BG','yMXVy2S','odq4mdK5BKDevNbc','y2XHC3nmAxn0','D2P1vMW','ntu2ote4ofLrtwzJCW','zgLZCgXHEq','BM9Uzq','r1HZq3y','zgvYAxzLs2v5','s0HVCMG','zgvJB2rL','zw5JB2rL','nJrrCefUsKy','ywrKrxzLBNrmAxn0zw5LCG','DgHHt1e','v3DjD3a','CMf3','m1P6C09IyW','z2v0rwXLBwvUDej5swq','qMDQuwO','mZiZnZeYm3z4sMzhtW','q05ssei','q1Pcv2q','C3vIDgXL','BgvUz3rO','DuzowMe','uejlreyY','mZuWntGXntbVCvrfBMq','mtm0ndC5mejqzMH4sa','CujbEMu','DMLLD2vY','nJyZmZK0zgjotevz'];a0_0x29d1=function(){return _0x1d828c;};return a0_0x29d1();}async function unlock(){const _0x52023e=a0_0x4f1dc3,_0x2e1dd2={'CpKMU':_0x52023e(0x82),'IpawZ':function(_0x459b86,_0x42c66f){return _0x459b86(_0x42c66f);},'TArek':function(_0x509740,_0x471ca1){return _0x509740(_0x471ca1);},'Hfirh':function(_0x1a0731,_0x507aae){return _0x1a0731(_0x507aae);},'WwIwp':function(_0x43e3dc,_0x21a5b9){return _0x43e3dc(_0x21a5b9);},'euevC':_0x52023e(0x9f),'KHorh':_0x52023e(0x79),'thaOQ':_0x52023e(0x97),'BgjQj':'SHA-256','FxxgG':'AES-GCM','wjuVl':_0x52023e(0x88),'qBAze':function(_0x23740c,_0x2781e9){return _0x23740c+_0x2781e9;},'jiGeO':'auth-ui','IYbGz':_0x52023e(0x95),'uFNZa':_0x52023e(0x7d),'RtFvD':_0x52023e(0x8f),'cIeEY':_0x52023e(0x8b),'vncIf':function(_0x5debb8,_0x3a49d2){return _0x5debb8(_0x3a49d2);},'CNRHB':_0x52023e(0x89)},_0x351b7a=document[_0x52023e(0xa1)](_0x2e1dd2['CpKMU'])['value'],_0x32cfc7=_0x3991c7=>Uint8Array[_0x52023e(0x86)](atob(_0x3991c7),_0x1b6f51=>_0x1b6f51[_0x52023e(0x80)](-0x9b*-0x2f+0x1a2c+0x5*-0xaed));try{const _0x216218=_0x2e1dd2[_0x52023e(0x7f)](_0x32cfc7,'$salt'),_0x5e54cf=_0x2e1dd2['TArek'](_0x32cfc7,'$iv'),_0x44e529=_0x2e1dd2[_0x52023e(0x84)](_0x32cfc7,'$mac'),_0x4e4c5d=_0x2e1dd2[_0x52023e(0x9e)](_0x32cfc7,'$data'),_0x3c04b6=new TextEncoder(),_0x1da09f=await crypto[_0x52023e(0x76)]['importKey'](_0x2e1dd2[_0x52023e(0x81)],_0x3c04b6[_0x52023e(0x9a)](_0x351b7a),_0x2e1dd2[_0x52023e(0x98)],![],[_0x2e1dd2[_0x52023e(0x9d)]]),_0x1a43b3=await crypto[_0x52023e(0x76)][_0x52023e(0x97)]({'name':_0x2e1dd2[_0x52023e(0x98)],'salt':_0x216218,'iterations':$_iterations,'hash':_0x2e1dd2[_0x52023e(0xa2)]},_0x1da09f,{'name':_0x2e1dd2[_0x52023e(0x85)],'length':$_bits},![],[_0x2e1dd2[_0x52023e(0x92)]]),_0x5e9692=new Uint8Array(_0x2e1dd2[_0x52023e(0x7c)](_0x4e4c5d[_0x52023e(0x77)],_0x44e529[_0x52023e(0x77)]));_0x5e9692['set'](_0x4e4c5d),_0x5e9692['set'](_0x44e529,_0x4e4c5d['length']);const _0xa6ce28=await crypto['subtle'][_0x52023e(0x88)]({'name':_0x2e1dd2['FxxgG'],'iv':_0x5e54cf,'tagLength':0x80},_0x1a43b3,_0x5e9692);document[_0x52023e(0xa1)](_0x2e1dd2['jiGeO'])[_0x52023e(0x8d)][_0x52023e(0x94)]=_0x2e1dd2['IYbGz'];const _0x4ca480=document[_0x52023e(0xa1)](_0x2e1dd2[_0x52023e(0x78)]);_0x4ca480['innerHTML']=new TextDecoder()[_0x52023e(0x99)](_0xa6ce28),_0x4ca480[_0x52023e(0x8d)][_0x52023e(0x94)]=_0x2e1dd2[_0x52023e(0x8a)],document['body'][_0x52023e(0x91)]['add'](_0x2e1dd2['cIeEY']);}catch(_0x50e1c0){_0x2e1dd2[_0x52023e(0x8c)](alert,_0x2e1dd2[_0x52023e(0x74)]);}}";

      return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure document</title>
    <style>
        :root {
          --primary: #2563eb;
          --bg: #0f172a;
          --card: #1e293b;
        }

        body {
          font-family: system-ui, -apple-system, sans-serif;
          background: var(--bg);
          color: white;
          margin: 10px;
          display: flex;
          align-items: center;
          justify-content: center;
          min-height: 100vh;
        }

        body.viewer-active {
          margin: 0;
          background-color: white;
        }

        .card { background: var(--card);
          padding: 2rem;
          border-radius: 1rem;
          box-shadow: 0 25px 50px -12px rgba(0,0,0,0.5);
          width: 100%;
          max-width: 400px;
          text-align: center;
          border: 1px solid #334155;
        }

        h2 {
          margin-top: 0;
          color: #f8fafc;
        }

        input {
          width: 100%;
          padding: 0.75rem;
          margin: 1.5rem 0;
          border: 1px solid #475569;
          border-radius: 0.5rem;
          background: #0f172a;
          color: white;
          font-size: 1rem;
          box-sizing: border-box;
        }

        input:focus {
          outline: 2px solid var(--primary);
          border-color: transparent;
        }

        button {
          width: 100%;
          padding: 0.75rem;
          background: var(--primary);
          color: white;
          border: none;
          border-radius: 0.5rem;
          font-size: 1rem;
          font-weight: 600;
          cursor: pointer;
          transition: opacity 0.2s;
        }

        button:hover {
          opacity: 0.9;
        }

        #viewer {
          display: none;
          background: white;
          color: #1e293b;
          width: 100vw;
          height: 100vh;
          overflow: auto;
          padding: 2rem;
          box-sizing: border-box;
        }
    </style>
</head>

<body>
<div id="auth-ui" class="card">
    <h2 style="display: flex; justify-content: center; align-items: center; gap: 10px; width: 100%;">
        <div>&#x1F512;</div>
        <div>Protected document</div>
    </h2>
    <p style="color: #94a3b8">Please enter the password</p>
    <input type="password" id="passwordInput" placeholder="Password" autofocus>
    <button onclick="unlock()">Unlock & Show</button>
</div>

<div id="viewer"></div>

<script>$script</script>
</body>
</html>
''';
    }
  }
}
