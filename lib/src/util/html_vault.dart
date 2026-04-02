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
        let errorTimeout;

        function showError() {
            const errorEl = document.getElementById('error-message');
            errorEl.style.visibility = 'visible';
            errorEl.style.opacity = '1';

            if (errorTimeout) clearTimeout(errorTimeout);

            // show max. 5 seconds
            errorTimeout = setTimeout(hideError, 5000);
        }

        function hideError() {
            if (errorTimeout) {
                clearTimeout(errorTimeout);
                errorTimeout = null;
            }

            const errorEl = document.getElementById('error-message');
            errorEl.style.opacity = '0';

            //wait for transition before hiding
            setTimeout(() => {
                if(errorEl.style.opacity === '0') errorEl.style.visibility = 'hidden';
            }, 300);
        }

        // remove error when typing
        document.getElementById('passwordInput').addEventListener('input', hideError);

        // We don't use onkeypress because it's deprecated, so use event listener for "Enter" key
        document.getElementById('passwordInput').addEventListener('keydown', function(event) {
            if (event.key === 'Enter') {
                unlock();
            }
        });

        async function unlock() {
            hideError();

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

                // Initialize scripts because some browsers won't do this (security!)

                //REMOVE "old" scripts
                const oldScripts = document.querySelectorAll('.vault-injected-script');
                oldScripts.forEach(script => script.remove());

                //Check for "new" scripts
                const scripts = v.getElementsByTagName("script");

                // allows safe manipulation
                const scriptArray = Array.from(scripts);

                scriptArray.forEach(oldScript => {
                    const newScript = document.createElement("script");
                    newScript.text = oldScript.innerText;
                    //marker for "new" script
                    newScript.className = 'vault-injected-script';

                    document.body.appendChild(newScript);

                    //remove script from content
                    oldScript.remove();
                });
            } catch (e) {
                showError();

                console.error('Decryption failed:', e);
            }
        }
*/
      //see test/html/minify_script.dart
      String script = "const a0_0x2b4947=a0_0x2222;function a0_0x3eb6(){const _0xce70ee=['CMf3','y3jLyxrLrwXLBwvUDa','z2v0rwXLBwvUDhncEvrHz05HBwu','DMf1BhqTAw5Qzwn0zwqTC2nYAxb0','qNr2CKu','CMvTB3zL','tKfLCgu','C2nYAxb0','y2XHC3noyw1L','A2v5zg93BG','nJyXnZzJrNfxvxi','yxbWzw5Kq2HPBgq','Aw5WDxq','zfzXCfG','zgvJCNLWDa','mtjowKn3tuK','zNz6wuy','uejlreyY','t1HYy3e','uw9yrK8','DNPbu0O','y2HHCKnVzgvbDa','zxjYB3iTBwvZC2fNzq','DhHzzMW','ywrKrxzLBNrmAxn0zw5LCG','vg9Us3K','wNnkCM4','zgvYAxzLs2v5','EeXpAKS','DMLZAwjSzq','mJK0oti3mLnAtw9vBq','n1jKwvr4Eq','yMXVy2S','AgLKzgvU','swHPreW','C3r5Bgu','A3vnCMu','nJy3mdy2u09TzNvL','DMLZAwjPBgL0Eq','ndC2ndmXmK1Pu1nUwa','v0jLC3K','Bu9OB2q','quvtluDdtq','zNjVBq','Dgv4Da','zgLZCgXHEq','mJq4oti0nvPYs0TdzG','Aw1WB3j0s2v5','vuf5wLq','DMfSDwu','Aw5UzxjuzxH0','DMLLD2vY','nde0mgPHtgrSBq','vhjVwgO','AhnbsKi','y1j1s08','C2v0','z2v0rwXLBwvUDej5swq','yM9KEq','yuLfCLC','B3bHy2L0Eq','A2v5','y09ezfa','CgfZC3DVCMrjBNb1Da','neDLAhLWuG','BgvUz3rO','C3vIDgXL','qLr2AvG','qwjMy1a','zxjYB3i','oti0ota2zvb2Cxrr','zw5JB2rL','ywrK','nZC5mJm4z01yt2LQ','zgvJB2rL','zxDAs0K','rujyrxi','y2XHC3nmAxn0','u0LzwgG','rgvJCNLWDgLVBIbMywLSzwq6','CxvLCNLtzwXLy3rVCKfSBa','v214Axq','Aw5Uzxjive1m','DMLLD2vYlwfJDgL2zq','zM9YrwfJAa','BM9Uzq'];a0_0x3eb6=function(){return _0xce70ee;};return a0_0x3eb6();}function a0_0x2222(_0xfb055,_0x3f7de4){_0xfb055=_0xfb055-(-0x5*-0x7ac+0x1*-0x1309+-0x11cd);const _0x389a96=a0_0x3eb6();let _0x2011c6=_0x389a96[_0xfb055];if(a0_0x2222['gdZaKk']===undefined){var _0x584c8f=function(_0x1e3378){const _0x4367ff='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/=';let _0x83bd9c='',_0x44a5ec='';for(let _0x1c419a=0x1*-0x2403+0x1192+-0x1271*-0x1,_0x485c45,_0x1efb7a,_0x53f61e=-0xff*0x1b+0xd73+0xd72*0x1;_0x1efb7a=_0x1e3378['charAt'](_0x53f61e++);~_0x1efb7a&&(_0x485c45=_0x1c419a%(-0xc01+0xdab+-0xd3*0x2)?_0x485c45*(0x6*0x114+0x2bc+-0x8f4)+_0x1efb7a:_0x1efb7a,_0x1c419a++%(0x3d*0xb+-0x1e53+0x1bb8))?_0x83bd9c+=String['fromCharCode'](-0xc9d+0x138a*0x1+-0x5ee&_0x485c45>>(-(0x1*-0x235f+-0xd88+0x30e9)*_0x1c419a&0x21e+0xf11+-0x1129)):0x1*-0x1024+-0x6*-0x3e4+-0x734){_0x1efb7a=_0x4367ff['indexOf'](_0x1efb7a);}for(let _0x2e5013=-0x2301*-0x1+0x1*0x1fee+-0x42ef,_0x49a2ad=_0x83bd9c['length'];_0x2e5013<_0x49a2ad;_0x2e5013++){_0x44a5ec+='%'+('00'+_0x83bd9c['charCodeAt'](_0x2e5013)['toString'](-0x1*0x1069+-0x2080+0x255*0x15))['slice'](-(-0x1ecf+0xac*-0xb+-0x2635*-0x1));}return decodeURIComponent(_0x44a5ec);};a0_0x2222['emUQQy']=_0x584c8f,a0_0x2222['jUOsGD']={},a0_0x2222['gdZaKk']=!![];}const _0x597860=_0x389a96[0x1*0x1885+0x1*-0x10fd+-0x3c4*0x2],_0x84606f=_0xfb055+_0x597860,_0x33b3be=a0_0x2222['jUOsGD'][_0x84606f];return!_0x33b3be?(_0x2011c6=a0_0x2222['emUQQy'](_0x2011c6),a0_0x2222['jUOsGD'][_0x84606f]=_0x2011c6):_0x2011c6=_0x33b3be,_0x2011c6;}(function(_0x4cd4d8,_0xa4a523){const _0x940071=a0_0x2222,_0x15b8ad=_0x4cd4d8();while(!![]){try{const _0x265116=-parseInt(_0x940071(0x193))/(-0x2512+-0xc5*0x2a+0x4565)*(-parseInt(_0x940071(0x1ce))/(-0x607*-0x2+-0x3a6*0x1+-0x866*0x1))+-parseInt(_0x940071(0x199))/(-0xa88*-0x2+-0x4a*-0x1+-0x1557)+parseInt(_0x940071(0x1b8))/(0x2f*0xa0+-0x41*-0x8b+0x3*-0x158d)*(-parseInt(_0x940071(0x1d7))/(-0x9c3+0x8dc*0x2+-0x7f0))+-parseInt(_0x940071(0x19c))/(-0x383+0xad2+-0x749)+-parseInt(_0x940071(0x1c8))/(0x44f*-0x5+-0x1*0xd13+0xb5*0x31)*(parseInt(_0x940071(0x1c7))/(0x1e8e+0x625+-0x24ab))+-parseInt(_0x940071(0x1d0))/(0x2102+0x1fc4+0x40bd*-0x1)+-parseInt(_0x940071(0x187))/(-0x5e5+0x1*-0x243+0x419*0x2)*(-parseInt(_0x940071(0x1b3))/(-0x2691*-0x1+-0x1a7a+-0x101*0xc));if(_0x265116===_0xa4a523)break;else _0x15b8ad['push'](_0x15b8ad['shift']());}catch(_0xdaeef7){_0x15b8ad['push'](_0x15b8ad['shift']());}}}(a0_0x3eb6,0x16f112+-0x6ed*-0x1f5+-0x155024));let errorTimeout;function showError(){const _0x2577d6=a0_0x2222,_0x1b1597={'ZsJrn':_0x2577d6(0x1bf),'EBXEr':_0x2577d6(0x1c6),'RRaar':function(_0x731167,_0x57fd12){return _0x731167(_0x57fd12);},'OXrcq':function(_0xa7819e,_0x32c10b,_0x3212c1){return _0xa7819e(_0x32c10b,_0x3212c1);}},_0x430dbe=document[_0x2577d6(0x18c)](_0x1b1597[_0x2577d6(0x1c3)]);_0x430dbe[_0x2577d6(0x1cc)]['visibility']=_0x1b1597[_0x2577d6(0x19f)],_0x430dbe[_0x2577d6(0x1cc)][_0x2577d6(0x18f)]='1';if(errorTimeout)_0x1b1597['RRaar'](clearTimeout,errorTimeout);errorTimeout=_0x1b1597[_0x2577d6(0x1bb)](setTimeout,hideError,0x5d1+0x206f+-0x12b8*0x1);}function hideError(){const _0x3b343f=a0_0x2222,_0x4fa36a={'BTviX':function(_0x80b5e3,_0x2be2b6){return _0x80b5e3===_0x2be2b6;},'NAepe':_0x3b343f(0x1ca),'ZRfvx':function(_0x4bddcc,_0x452a80){return _0x4bddcc(_0x452a80);},'QoXFO':_0x3b343f(0x1bf),'aIErW':function(_0x438bc8,_0x3fb15e,_0x142d84){return _0x438bc8(_0x3fb15e,_0x142d84);}};errorTimeout&&(_0x4fa36a['ZRfvx'](clearTimeout,errorTimeout),errorTimeout=null);const _0x5362e7=document['getElementById'](_0x4fa36a[_0x3b343f(0x1bc)]);_0x5362e7[_0x3b343f(0x1cc)][_0x3b343f(0x18f)]='0',_0x4fa36a[_0x3b343f(0x18e)](setTimeout,()=>{const _0x5dc9d9=_0x3b343f;if(_0x4fa36a[_0x5dc9d9(0x196)](_0x5362e7[_0x5dc9d9(0x1cc)][_0x5dc9d9(0x18f)],'0'))_0x5362e7['style'][_0x5dc9d9(0x1cf)]=_0x4fa36a[_0x5dc9d9(0x1af)];},0x1e48+0x5*0x43+-0xd*0x257);}document['getElementById'](a0_0x2b4947(0x192))[a0_0x2b4947(0x1c1)](a0_0x2b4947(0x1b5),hideError),document[a0_0x2b4947(0x18c)](a0_0x2b4947(0x192))['addEventListener'](a0_0x2b4947(0x1b2),function(_0x1c8691){const _0x1c246e=a0_0x2b4947,_0x1729b3={'zOqAZ':function(_0x34e36a,_0x55ddec){return _0x34e36a===_0x55ddec;},'dVqpX':'Enter','SIYXh':function(_0x5aa9b4){return _0x5aa9b4();}};_0x1729b3['zOqAZ'](_0x1c8691[_0x1c246e(0x190)],_0x1729b3[_0x1c246e(0x1b6)])&&_0x1729b3[_0x1c246e(0x1a1)](unlock);});async function unlock(){const _0x1329e6=a0_0x2b4947,_0x40aeaa={'mOhod':_0x1329e6(0x1b0),'ewZKI':_0x1329e6(0x1ac),'fvzYF':function(_0x21bc87){return _0x21bc87();},'WBesy':'passwordInput','cRuKO':function(_0x4d854f,_0x31fdd6){return _0x4d854f(_0x31fdd6);},'expcQ':function(_0x4a8ea8,_0x590285){return _0x4a8ea8(_0x590285);},'TroXj':_0x1329e6(0x1a9),'AbfcP':_0x1329e6(0x1ba),'hsAJB':_0x1329e6(0x1c4),'UAyZT':'SHA-256','cODdP':_0x1329e6(0x1d3),'TonKy':_0x1329e6(0x1b7),'Wmxit':function(_0x5e4aa8,_0x473e7a){return _0x5e4aa8+_0x473e7a;},'brHIn':'auth-ui','IhiDL':_0x1329e6(0x1a8),'txYfl':_0x1329e6(0x186),'vzASJ':_0x1329e6(0x1c9),'xLOjK':_0x1329e6(0x1a6),'kuMre':'.vault-injected-script','BtvrE':_0x1329e6(0x1a2)};_0x40aeaa['fvzYF'](hideError);const _0x259df1=document['getElementById'](_0x40aeaa[_0x1329e6(0x1d1)])[_0x1329e6(0x1da)],_0x1220fd=_0x4f0ab4=>Uint8Array[_0x1329e6(0x1d4)](atob(_0x4f0ab4),_0x4c444d=>_0x4c444d[_0x1329e6(0x1be)](0x17c8+0x1*0x13a9+-0x2b71));try{const _0x1d3138=_0x40aeaa[_0x1329e6(0x18a)](_0x1220fd,'$salt'),_0x577bd8=_0x40aeaa['cRuKO'](_0x1220fd,'$iv'),_0x4854b3=_0x40aeaa['cRuKO'](_0x1220fd,'$mac'),_0x5170b3=_0x40aeaa['expcQ'](_0x1220fd,'$data'),_0x1e4562=new TextEncoder(),_0x341d78=await crypto['subtle'][_0x1329e6(0x1d8)](_0x40aeaa[_0x1329e6(0x188)],_0x1e4562[_0x1329e6(0x19a)](_0x259df1),_0x40aeaa[_0x1329e6(0x197)],![],[_0x40aeaa[_0x1329e6(0x189)]]),_0x6e4696=await crypto[_0x1329e6(0x195)][_0x1329e6(0x1c4)]({'name':_0x40aeaa[_0x1329e6(0x197)],'salt':_0x1d3138,'iterations':$_iterations,'hash':_0x40aeaa[_0x1329e6(0x1d9)]},_0x341d78,{'name':_0x40aeaa[_0x1329e6(0x191)],'length':$_bits},![],[_0x40aeaa[_0x1329e6(0x1c2)]]),_0x483da5=new Uint8Array(_0x40aeaa[_0x1329e6(0x1a4)](_0x5170b3[_0x1329e6(0x194)],_0x4854b3[_0x1329e6(0x194)]));_0x483da5['set'](_0x5170b3),_0x483da5[_0x1329e6(0x18b)](_0x4854b3,_0x5170b3['length']);const _0x7f7a24=await crypto['subtle'][_0x1329e6(0x1b7)]({'name':_0x40aeaa[_0x1329e6(0x191)],'iv':_0x577bd8,'tagLength':0x80},_0x6e4696,_0x483da5);document[_0x1329e6(0x18c)](_0x40aeaa['brHIn'])[_0x1329e6(0x1cc)][_0x1329e6(0x1d6)]=_0x40aeaa[_0x1329e6(0x1cb)];const _0x5f35c6=document[_0x1329e6(0x18c)](_0x40aeaa[_0x1329e6(0x1c0)]);_0x5f35c6[_0x1329e6(0x1a5)]=new TextDecoder()[_0x1329e6(0x19d)](_0x7f7a24),_0x5f35c6[_0x1329e6(0x1cc)][_0x1329e6(0x1d6)]=_0x40aeaa[_0x1329e6(0x1bd)],document['body'][_0x1329e6(0x1a0)][_0x1329e6(0x19b)](_0x40aeaa[_0x1329e6(0x1c5)]);const _0x2e63e6=document[_0x1329e6(0x1a3)](_0x40aeaa[_0x1329e6(0x1cd)]);_0x2e63e6[_0x1329e6(0x1a7)](_0x23f51b=>_0x23f51b[_0x1329e6(0x1ae)]());const _0x14ed28=_0x5f35c6[_0x1329e6(0x1ab)](_0x40aeaa[_0x1329e6(0x1d2)]),_0x3970cf=Array[_0x1329e6(0x1d4)](_0x14ed28);_0x3970cf['forEach'](_0x144437=>{const _0x15541a=_0x1329e6,_0x311964=document[_0x15541a(0x1aa)](_0x40aeaa[_0x15541a(0x1d2)]);_0x311964[_0x15541a(0x1d5)]=_0x144437[_0x15541a(0x1db)],_0x311964[_0x15541a(0x1b1)]=_0x40aeaa[_0x15541a(0x19e)],document[_0x15541a(0x18d)][_0x15541a(0x1b4)](_0x311964),_0x144437[_0x15541a(0x1ae)]();});}catch(_0x7e6c7e){_0x40aeaa[_0x1329e6(0x1b9)](showError),console[_0x1329e6(0x198)](_0x40aeaa[_0x1329e6(0x1ad)],_0x7e6c7e);}}";

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

        #error-message {
          color: #ef4444;
          font-size: 0.875rem;
          font-weight: 600;
          margin-top: -0.5rem;
          margin-bottom: 1rem;
          min-height: 1.25rem;
          visibility: hidden;
          transition: opacity 0.3s;
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
    <input type="password" id="passwordInput" placeholder="Password" autofocus></input>
    <div id="error-message">- Wrong password -</div>
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
