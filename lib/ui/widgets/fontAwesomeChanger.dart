import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

bool checkFontAwesome(String text) {
  if (text.contains('FontAwesome')) {
    return true;
  }
  return false;
}

formatFontAwesomeText(String text) {
  if (!checkFontAwesome(text)) 
    return "This is no fontawesome string";
  
  List<String> arr = text.split(';');

  String icon = arr[0];

  arr.removeAt(0);

  Map<String, dynamic> keyValue = <String, dynamic>{};

  arr.forEach((f) {
    var att = f.split('=');
    keyValue['${att[0]}'] = att[1];
  });

  IconData data = chooseIcon(convertToMethodName(icon));
  keyValue['icon'] = data;
  

  return keyValue;
}

String convertToMethodName(String text) {
  List strinArr = List<String>.from(text.split(''));

  strinArr.removeRange(0, 12);

  for (int i = 0; i < strinArr.length; i++) {
    String currentChar = strinArr[i];

    if (currentChar == '-') {
      strinArr[i + 1] = strinArr[i + 1].toUpperCase();
      strinArr.removeAt(strinArr.indexOf(currentChar));
    }
  }

  return strinArr.join();
}

IconData chooseIcon(String icon) {
  switch (icon) {
    case 'glass':
      return FontAwesomeIcons.glassWhiskey;
      break;
    case 'music':
      return FontAwesomeIcons.music;
      break;
    case 'search':
      return FontAwesomeIcons.search;
      break;
    case 'envelopeO':
      return FontAwesomeIcons.solidEnvelope;
      break;
    case 'heart':
      return FontAwesomeIcons.heart;
      break;
    case 'star':
      return FontAwesomeIcons.star;
      break;
    case 'starO':
      return FontAwesomeIcons.solidStar;
      break;
    case 'user':
      return FontAwesomeIcons.user;
      break;
    case 'film':
      return FontAwesomeIcons.film;
      break;
    case 'thLarge':
      return FontAwesomeIcons.thLarge;
      break;
    case 'th':
      return FontAwesomeIcons.th;
      break;
    case 'thList':
      return FontAwesomeIcons.thList;
      break;
    case 'check':
      return FontAwesomeIcons.check;
      break;
    case 'remove':
      return FontAwesomeIcons.trashAlt;
      break;
    case 'close':
      return FontAwesomeIcons.times;
      break;
    case 'times':
      return FontAwesomeIcons.times;
      break;
    case 'searchPlus':
      return FontAwesomeIcons.searchPlus;
      break;
    case 'searchMinus':
      return FontAwesomeIcons.searchMinus;
      break;
    case 'powerOff':
      return FontAwesomeIcons.powerOff;
      break;
    case 'signal':
      return FontAwesomeIcons.signal;
      break;
    case 'gear':
      return FontAwesomeIcons.cogs;
      break;
    case 'cog':
      return FontAwesomeIcons.cog;
      break;
    case 'trashO':
      return FontAwesomeIcons.solidTrashAlt;
      break;
    case 'home':
      return FontAwesomeIcons.home;
      break;
    case 'fileO':
      return FontAwesomeIcons.solidFile;
      break;
    case 'clockO':
      return FontAwesomeIcons.solidClock;
      break;
    case 'road':
      return FontAwesomeIcons.road;
      break;
    case 'download':
      return FontAwesomeIcons.download;
      break;
    case 'arrowCircleODown':
      return FontAwesomeIcons.solidArrowAltCircleDown;
      break;
    case 'arrowCircleOUp':
      return FontAwesomeIcons.solidArrowAltCircleUp;
      break;
    case 'inbox':
      return FontAwesomeIcons.inbox;
      break;
    case 'playCircleO':
      return FontAwesomeIcons.solidPlayCircle;
      break;
    case 'rotateRight':
      return FontAwesomeIcons.sync;
      break;
    case 'repeat':
      return FontAwesomeIcons.redoAlt;
      break;
    case 'refresh':
      return FontAwesomeIcons.redo;
      break;
    case 'listAlt':
      return FontAwesomeIcons.listAlt;
      break;
    case 'lock':
      return FontAwesomeIcons.lock;
      break;
    case 'flag':
      return FontAwesomeIcons.flag;
      break;
    case 'headphones':
      return FontAwesomeIcons.headphones;
      break;
    case 'volumeOff':
      return FontAwesomeIcons.volumeOff;
      break;
    case 'volumeDown':
      return FontAwesomeIcons.volumeDown;
      break;
    case 'volumeUp':
      return FontAwesomeIcons.volumeUp;
      break;
    case 'qrcode':
      return FontAwesomeIcons.qrcode;
      break;
    case 'barcode':
      return FontAwesomeIcons.barcode;
      break;
    case 'tag':
      return FontAwesomeIcons.tag;
      break;
    case 'tags':
      return FontAwesomeIcons.tags;
      break;
    case 'book':
      return FontAwesomeIcons.book;
      break;
    case 'bookmark':
      return FontAwesomeIcons.bookmark;
      break;
    case 'print':
      return FontAwesomeIcons.print;
      break;
    case 'camera':
      return FontAwesomeIcons.camera;
      break;
    case 'font':
      return FontAwesomeIcons.font;
      break;
    case 'bold':
      return FontAwesomeIcons.bold;
      break;
    case 'italic':
      return FontAwesomeIcons.italic;
      break;
    case 'textHeight':
      return FontAwesomeIcons.textHeight;
      break;
    case 'textWidth':
      return FontAwesomeIcons.textWidth;
      break;
    case 'alignLeft':
      return FontAwesomeIcons.alignLeft;
      break;
    case 'alignCenter':
      return FontAwesomeIcons.alignCenter;
      break;
    case 'alignRight':
      return FontAwesomeIcons.alignRight;
      break;
    case 'alignJustify':
      return FontAwesomeIcons.alignJustify;
      break;
    case 'list':
      return FontAwesomeIcons.list;
      break;
    case 'dedent':
      return FontAwesomeIcons.outdent;
      break;
    case 'outdent':
      return FontAwesomeIcons.outdent;
      break;
    case 'indent':
      return FontAwesomeIcons.indent;
      break;
    case 'videoCamera':
      return FontAwesomeIcons.video;
      break;
    case 'photo':
      return FontAwesomeIcons.image;
      break;
    case 'image':
      return FontAwesomeIcons.image;
      break;
    case 'pictureO':
      return FontAwesomeIcons.solidImage;
      break;
    case 'pencil':
      return FontAwesomeIcons.pencilAlt;
      break;
    case 'mapMarker':
      return FontAwesomeIcons.mapMarker;
      break;
    case 'adjust':
      return FontAwesomeIcons.adjust;
      break;
    case 'tint':
      return FontAwesomeIcons.tint;
      break;
    case 'edit':
      return FontAwesomeIcons.edit;
      break;
    case 'pencilSquareO':
      return FontAwesomeIcons.penSquare;
      break;
    case 'shareSquareO':
      return FontAwesomeIcons.solidShareSquare;
      break;
    case 'checkSquareO':
      return FontAwesomeIcons.solidCheckSquare;
      break;
    case 'arrows':
      return FontAwesomeIcons.arrowsAlt;
      break;
    case 'stepBackward':
      return FontAwesomeIcons.stepBackward;
      break;
    case 'fastBackward':
      return FontAwesomeIcons.fastBackward;
      break;
    case 'backward':
      return FontAwesomeIcons.backward;
      break;
    case 'play':
      return FontAwesomeIcons.play;
      break;
    case 'pause':
      return FontAwesomeIcons.pause;
      break;
    case 'stop':
      return FontAwesomeIcons.stop;
      break;
    case 'forward':
      return FontAwesomeIcons.forward;
      break;
    case 'fastForward':
      return FontAwesomeIcons.fastForward;
      break;
    case 'stepForward':
      return FontAwesomeIcons.stepForward;
      break;
    case 'eject':
      return FontAwesomeIcons.eject;
      break;
    case 'chevronLeft':
      return FontAwesomeIcons.chevronLeft;
      break;
    case 'chevronRight':
      return FontAwesomeIcons.chevronRight;
      break;
    case 'plusCircle':
      return FontAwesomeIcons.plusCircle;
      break;
    case 'minusCircle':
      return FontAwesomeIcons.minusCircle;
      break;
    case 'timesCircle':
      return FontAwesomeIcons.timesCircle;
      break;
    case 'checkCircle':
      return FontAwesomeIcons.checkCircle;
      break;
    case 'questionCircle':
      return FontAwesomeIcons.questionCircle;
      break;
    case 'infoCircle':
      return FontAwesomeIcons.infoCircle;
      break;
    case 'crosshairs':
      return FontAwesomeIcons.crosshairs;
      break;
    case 'timesCircleO':
      return FontAwesomeIcons.solidTimesCircle;
      break;
    case 'checkCircleO':
      return FontAwesomeIcons.solidCheckCircle;
      break;
    case 'ban':
      return FontAwesomeIcons.ban;
      break;
    case 'arrowLeft':
      return FontAwesomeIcons.arrowLeft;
      break;
    case 'arrowRight':
      return FontAwesomeIcons.arrowRight;
      break;
    case 'arrowUp':
      return FontAwesomeIcons.arrowUp;
      break;
    case 'arrowDown':
      return FontAwesomeIcons.arrowDown;
      break;
    case 'mailForward':
      return FontAwesomeIcons.share;
      break;
    case 'share':
      return FontAwesomeIcons.share;
      break;
    case 'expand':
      return FontAwesomeIcons.expand;
      break;
    case 'compress':
      return FontAwesomeIcons.compress;
      break;
    case 'plus':
      return FontAwesomeIcons.plus;
      break;
    case 'minus':
      return FontAwesomeIcons.minus;
      break;
    case 'asterisk':
      return FontAwesomeIcons.asterisk;
      break;
    case 'exclamationCircle':
      return FontAwesomeIcons.exclamationCircle;
      break;
    case 'gift':
      return FontAwesomeIcons.gift;
      break;
    case 'leaf':
      return FontAwesomeIcons.leaf;
      break;
    case 'fire':
      return FontAwesomeIcons.fire;
      break;
    case 'eye':
      return FontAwesomeIcons.eye;
      break;
    case 'eyeSlash':
      return FontAwesomeIcons.eyeSlash;
      break;
    case 'warning':
      return FontAwesomeIcons.exclamation;
      break;
    case 'exclamationTriangle':
      return FontAwesomeIcons.exclamationTriangle;
      break;
    case 'plane':
      return FontAwesomeIcons.plane;
      break;
    case 'calendar':
      return FontAwesomeIcons.calendar;
      break;
    case 'random':
      return FontAwesomeIcons.random;
      break;
    case 'comment':
      return FontAwesomeIcons.comment;
      break;
    case 'magnet':
      return FontAwesomeIcons.magnet;
      break;
    case 'chevronUp':
      return FontAwesomeIcons.chevronUp;
      break;
    case 'chevronDown':
      return FontAwesomeIcons.chevronDown;
      break;
    case 'retweet':
      return FontAwesomeIcons.retweet;
      break;
    case 'shoppingCart':
      return FontAwesomeIcons.shoppingCart;
      break;
    case 'folder':
      return FontAwesomeIcons.folder;
      break;
    case 'folderOpen':
      return FontAwesomeIcons.folderOpen;
      break;
    case 'arrowsV':
      return FontAwesomeIcons.arrowsAltV;
      break;
    case 'arrowsH':
      return FontAwesomeIcons.arrowsAltH;
      break;
    case 'barChartO':
      return FontAwesomeIcons.solidChartBar;
      break;
    case 'barChart':
      return FontAwesomeIcons.chartBar;
      break;
    case 'twitterSquare':
      return FontAwesomeIcons.twitterSquare;
      break;
    case 'facebookSquare':
      return FontAwesomeIcons.facebookSquare;
      break;
    case 'cameraRetro':
      return FontAwesomeIcons.cameraRetro;
      break;
    case 'key':
      return FontAwesomeIcons.key;
      break;
    case 'gears':
      return FontAwesomeIcons.cogs;
      break;
    case 'cogs':
      return FontAwesomeIcons.cogs;
      break;
    case 'comments':
      return FontAwesomeIcons.comments;
      break;
    case 'thumbsOUp':
      return FontAwesomeIcons.solidThumbsUp;
      break;
    case 'thumbsODown':
      return FontAwesomeIcons.solidThumbsDown;
      break;
    case 'starHalf':
      return FontAwesomeIcons.starHalf;
      break;
    case 'heartO':
      return FontAwesomeIcons.solidHeart;
      break;
    case 'signOut':
      return FontAwesomeIcons.signOutAlt;
      break;
    case 'linkedinSquare':
      return FontAwesomeIcons.linkedin;
      break;
    case 'thumbTack':
      return FontAwesomeIcons.thumbtack;
      break;
    case 'externalLink':
      return FontAwesomeIcons.externalLinkAlt;
      break;
    case 'signIn':
      return FontAwesomeIcons.signInAlt;
      break;
    case 'trophy':
      return FontAwesomeIcons.trophy;
      break;
    case 'githubSquare':
      return FontAwesomeIcons.githubSquare;
      break;
    case 'upload':
      return FontAwesomeIcons.upload;
      break;
    case 'lemonO':
      return FontAwesomeIcons.solidLemon;
      break;
    case 'phone':
      return FontAwesomeIcons.phone;
      break;
    case 'squareO':
      return FontAwesomeIcons.solidSquare;
      break;
    case 'bookmarkO':
      return FontAwesomeIcons.solidBookmark;
      break;
    case 'phoneSquare':
      return FontAwesomeIcons.phoneSquare;
      break;
    case 'twitter':
      return FontAwesomeIcons.twitter;
      break;
    case 'facebookF':
      return FontAwesomeIcons.facebookF;
      break;
    case 'facebook':
      return FontAwesomeIcons.facebook;
      break;
    case 'github':
      return FontAwesomeIcons.github;
      break;
    case 'unlock':
      return FontAwesomeIcons.unlock;
      break;
    case 'creditCard':
      return FontAwesomeIcons.creditCard;
      break;
    case 'feed':
      return FontAwesomeIcons.rss;
      break;
    case 'rss':
      return FontAwesomeIcons.rss;
      break;
    case 'hddO':
      return FontAwesomeIcons.solidHdd;
      break;
    case 'bullhorn':
      return FontAwesomeIcons.bullhorn;
      break;
    case 'bell':
      return FontAwesomeIcons.bell;
      break;
    case 'certificate':
      return FontAwesomeIcons.certificate;
      break;
    case 'handORight':
      return FontAwesomeIcons.solidHandPointRight;
      break;
    case 'handOLeft':
      return FontAwesomeIcons.solidHandPointLeft;
      break;
    case 'handOUp':
      return FontAwesomeIcons.solidHandPointUp;
      break;
    case 'handODown':
      return FontAwesomeIcons.solidHandPointDown;
      break;
    case 'arrowCircleLeft':
      return FontAwesomeIcons.arrowCircleLeft;
      break;
    case 'arrowCircleRight':
      return FontAwesomeIcons.arrowCircleRight;
      break;
    case 'arrowCircleUp':
      return FontAwesomeIcons.arrowCircleUp;
      break;
    case 'arrowCircleDown':
      return FontAwesomeIcons.arrowCircleDown;
      break;
    case 'globe':
      return FontAwesomeIcons.globe;
      break;
    case 'wrench':
      return FontAwesomeIcons.wrench;
      break;
    case 'tasks':
      return FontAwesomeIcons.tasks;
      break;
    case 'filter':
      return FontAwesomeIcons.filter;
      break;
    case 'briefcase':
      return FontAwesomeIcons.briefcase;
      break;
    case 'arrowsAlt':
      return FontAwesomeIcons.arrowsAlt;
      break;
    case 'group':
      return FontAwesomeIcons.users;
      break;
    case 'users':
      return FontAwesomeIcons.users;
      break;
    case 'chain':
      return FontAwesomeIcons.link;
      break;
    case 'link':
      return FontAwesomeIcons.link;
      break;
    case 'cloud':
      return FontAwesomeIcons.cloud;
      break;
    case 'flask':
      return FontAwesomeIcons.flask;
      break;
    case 'cut':
      return FontAwesomeIcons.cut;
      break;
    case 'scissors':
      return FontAwesomeIcons.cut;
      break;
    case 'copy':
      return FontAwesomeIcons.copy;
      break;
    case 'filesO':
      return FontAwesomeIcons.solidFile;
      break;
    case 'paperclip':
      return FontAwesomeIcons.paperclip;
      break;
    case 'save':
      return FontAwesomeIcons.save;
      break;
    case 'floppyO':
      return FontAwesomeIcons.save;
      break;
    case 'square':
      return FontAwesomeIcons.square;
      break;
    case 'navicon':
      return FontAwesomeIcons.bars;
      break;
    case 'reorder':
      return FontAwesomeIcons.bars;
      break;
    case 'bars':
      return FontAwesomeIcons.bars;
      break;
    case 'listUl':
      return FontAwesomeIcons.listUl;
      break;
    case 'listOl':
      return FontAwesomeIcons.listOl;
      break;
    case 'strikethrough':
      return FontAwesomeIcons.strikethrough;
      break;
    case 'underline':
      return FontAwesomeIcons.underline;
      break;
    case 'table':
      return FontAwesomeIcons.table;
      break;
    case 'magic':
      return FontAwesomeIcons.magic;
      break;
    case 'truck':
      return FontAwesomeIcons.truck;
      break;
    case 'pinterest':
      return FontAwesomeIcons.pinterest;
      break;
    case 'pinterestSquare':
      return FontAwesomeIcons.pinterestSquare;
      break;
    case 'googlePlusSquare':
      return FontAwesomeIcons.googlePlusSquare;
      break;
    case 'googlePlus':
      return FontAwesomeIcons.googlePlus;
      break;
    case 'money':
      return FontAwesomeIcons.moneyBill;
      break;
    case 'caretDown':
      return FontAwesomeIcons.caretDown;
      break;
    case 'caretUp':
      return FontAwesomeIcons.caretUp;
      break;
    case 'caretLeft':
      return FontAwesomeIcons.caretLeft;
      break;
    case 'caretRight':
      return FontAwesomeIcons.caretRight;
      break;
    case 'columns':
      return FontAwesomeIcons.columns;
      break;
    case 'unsorted':
      return FontAwesomeIcons.sort;
      break;
    case 'sort':
      return FontAwesomeIcons.sort;
      break;
    case 'sortDown':
      return FontAwesomeIcons.sortDown;
      break;
    case 'sortDesc':
      return FontAwesomeIcons.sortNumericDown;
      break;
    case 'sortUp':
      return FontAwesomeIcons.sortUp;
      break;
    case 'sortAsc':
      return FontAwesomeIcons.sortNumericUp;
      break;
    case 'envelope':
      return FontAwesomeIcons.envelope;
      break;
    case 'linkedin':
      return FontAwesomeIcons.linkedin;
      break;
    case 'rotateLeft':
      return FontAwesomeIcons.undo;
      break;
    case 'undo':
      return FontAwesomeIcons.undo;
      break;
    case 'legal':
      return FontAwesomeIcons.gavel;
      break;
    case 'gavel':
      return FontAwesomeIcons.gavel;
      break;
    case 'dashboard':
      return FontAwesomeIcons.tachometerAlt;
      break;
    case 'tachometer':
      return FontAwesomeIcons.tachometerAlt;
      break;
    case 'commentO':
      return FontAwesomeIcons.solidComment;
      break;
    case 'commentsO':
      return FontAwesomeIcons.solidComments;
      break;
    case 'flash':
      return FontAwesomeIcons.bolt;
      break;
    case 'bolt':
      return FontAwesomeIcons.bolt;
      break;
    case 'sitemap':
      return FontAwesomeIcons.sitemap;
      break;
    case 'umbrella':
      return FontAwesomeIcons.umbrella;
      break;
    case 'paste':
      return FontAwesomeIcons.paste;
      break;
    case 'clipboard':
      return FontAwesomeIcons.clipboard;
      break;
    case 'lightbulbO':
      return FontAwesomeIcons.solidLightbulb;
      break;
    case 'exchange':
      return FontAwesomeIcons.exchangeAlt;
      break;
    case 'cloudDownload':
      return FontAwesomeIcons.cloudDownloadAlt;
      break;
    case 'cloudUpload':
      return FontAwesomeIcons.cloudUploadAlt;
      break;
    case 'userMd':
      return FontAwesomeIcons.userMd;
      break;
    case 'stethoscope':
      return FontAwesomeIcons.stethoscope;
      break;
    case 'suitcase':
      return FontAwesomeIcons.suitcase;
      break;
    case 'bellO':
      return FontAwesomeIcons.solidBell;
      break;
    case 'coffee':
      return FontAwesomeIcons.coffee;
      break;
    case 'cutlery':
      return FontAwesomeIcons.utensils;
      break;
    case 'fileTextO':
      return FontAwesomeIcons.solidFileAlt;
      break;
    case 'buildingO':
      return FontAwesomeIcons.solidBuilding;
      break;
    case 'hospitalO':
      return FontAwesomeIcons.solidHospital;
      break;
    case 'ambulance':
      return FontAwesomeIcons.ambulance;
      break;
    case 'medkit':
      return FontAwesomeIcons.medkit;
      break;
    case 'fighterJet':
      return FontAwesomeIcons.fighterJet;
      break;
    case 'beer':
      return FontAwesomeIcons.beer;
      break;
    case 'hSquare':
      return FontAwesomeIcons.hSquare;
      break;
    case 'plusSquare':
      return FontAwesomeIcons.plusSquare;
      break;
    case 'angleDoubleLeft':
      return FontAwesomeIcons.angleDoubleLeft;
      break;
    case 'angleDoubleRight':
      return FontAwesomeIcons.angleDoubleRight;
      break;
    case 'angleDoubleUp':
      return FontAwesomeIcons.angleDoubleUp;
      break;
    case 'angleDoubleDown':
      return FontAwesomeIcons.angleDoubleDown;
      break;
    case 'angleLeft':
      return FontAwesomeIcons.angleLeft;
      break;
    case 'angleRight':
      return FontAwesomeIcons.angleRight;
      break;
    case 'angleUp':
      return FontAwesomeIcons.angleUp;
      break;
    case 'angleDown':
      return FontAwesomeIcons.angleDown;
      break;
    case 'desktop':
      return FontAwesomeIcons.desktop;
      break;
    case 'laptop':
      return FontAwesomeIcons.laptop;
      break;
    case 'tablet':
      return FontAwesomeIcons.tablet;
      break;
    case 'mobilePhone':
      return FontAwesomeIcons.mobileAlt;
      break;
    case 'mobile':
      return FontAwesomeIcons.mobile;
      break;
    case 'circleO':
      return FontAwesomeIcons.solidCircle;
      break;
    case 'quoteLeft':
      return FontAwesomeIcons.quoteLeft;
      break;
    case 'quoteRight':
      return FontAwesomeIcons.quoteRight;
      break;
    case 'spinner':
      return FontAwesomeIcons.spinner;
      break;
    case 'circle':
      return FontAwesomeIcons.circle;
      break;
    case 'mailReply':
      return FontAwesomeIcons.reply;
      break;
    case 'reply':
      return FontAwesomeIcons.reply;
      break;
    case 'githubAlt':
      return FontAwesomeIcons.githubAlt;
      break;
    case 'folderO':
      return FontAwesomeIcons.solidFolder;
      break;
    case 'folderOpenO':
      return FontAwesomeIcons.solidFolderOpen;
      break;
    case 'smileO':
      return FontAwesomeIcons.solidSmile;
      break;
    case 'frownO':
      return FontAwesomeIcons.solidFrown;
      break;
    case 'mehO':
      return FontAwesomeIcons.solidMeh;
      break;
    case 'gamepad':
      return FontAwesomeIcons.gamepad;
      break;
    case 'keyboardO':
      return FontAwesomeIcons.solidKeyboard;
      break;
    case 'flagO':
      return FontAwesomeIcons.solidFlag;
      break;
    case 'flagCheckered':
      return FontAwesomeIcons.flagCheckered;
      break;
    case 'terminal':
      return FontAwesomeIcons.terminal;
      break;
    case 'code':
      return FontAwesomeIcons.code;
      break;
    case 'mailReplyAll':
      return FontAwesomeIcons.replyAll;
      break;
    case 'replyAll':
      return FontAwesomeIcons.replyAll;
      break;
    case 'starHalfEmpty':
      return FontAwesomeIcons.starHalfAlt;
      break;
    case 'starHalfFull':
      return FontAwesomeIcons.starHalfAlt;
      break;
    case 'starHalfO':
      return FontAwesomeIcons.solidStarHalf;
      break;
    case 'locationArrow':
      return FontAwesomeIcons.locationArrow;
      break;
    case 'crop':
      return FontAwesomeIcons.crop;
      break;
    case 'codeFork':
      return FontAwesomeIcons.codeBranch;
      break;
    case 'unlink':
      return FontAwesomeIcons.unlink;
      break;
    case 'chainBroken':
      return FontAwesomeIcons.unlink;
      break;
    case 'question':
      return FontAwesomeIcons.question;
      break;
    case 'info':
      return FontAwesomeIcons.info;
      break;
    case 'exclamation':
      return FontAwesomeIcons.exclamation;
      break;
    case 'superscript':
      return FontAwesomeIcons.superscript;
      break;
    case 'subscript':
      return FontAwesomeIcons.subscript;
      break;
    case 'eraser':
      return FontAwesomeIcons.eraser;
      break;
    case 'puzzlePiece':
      return FontAwesomeIcons.puzzlePiece;
      break;
    case 'microphone':
      return FontAwesomeIcons.microphone;
      break;
    case 'microphoneSlash':
      return FontAwesomeIcons.microphoneSlash;
      break;
    case 'shield':
      return FontAwesomeIcons.shieldAlt;
      break;
    case 'calendarO':
      return FontAwesomeIcons.solidCalendar;
      break;
    case 'fireExtinguisher':
      return FontAwesomeIcons.fireExtinguisher;
      break;
    case 'rocket':
      return FontAwesomeIcons.rocket;
      break;
    case 'maxcdn':
      return FontAwesomeIcons.maxcdn;
      break;
    case 'chevronCircleLeft':
      return FontAwesomeIcons.chevronCircleLeft;
      break;
    case 'chevronCircleRight':
      return FontAwesomeIcons.chevronCircleRight;
      break;
    case 'chevronCircleUp':
      return FontAwesomeIcons.chevronCircleUp;
      break;
    case 'chevronCircleDown':
      return FontAwesomeIcons.chevronCircleDown;
      break;
    case 'html5':
      return FontAwesomeIcons.html5;
      break;
    case 'css3':
      return FontAwesomeIcons.css3;
      break;
    case 'anchor':
      return FontAwesomeIcons.anchor;
      break;
    case 'unlockAlt':
      return FontAwesomeIcons.unlockAlt;
      break;
    case 'bullseye':
      return FontAwesomeIcons.bullseye;
      break;
    case 'ellipsisH':
      return FontAwesomeIcons.ellipsisH;
      break;
    case 'ellipsisV':
      return FontAwesomeIcons.ellipsisV;
      break;
    case 'rssSquare':
      return FontAwesomeIcons.rssSquare;
      break;
    case 'playCircle':
      return FontAwesomeIcons.playCircle;
      break;
    case 'ticket':
      return FontAwesomeIcons.ticketAlt;
      break;
    case 'minusSquare':
      return FontAwesomeIcons.minusSquare;
      break;
    case 'minusSquareO':
      return FontAwesomeIcons.solidMinusSquare;
      break;
    case 'levelUp':
      return FontAwesomeIcons.levelUpAlt;
      break;
    case 'levelDown':
      return FontAwesomeIcons.levelDownAlt;
      break;
    case 'checkSquare':
      return FontAwesomeIcons.checkSquare;
      break;
    case 'pencilSquare':
      return FontAwesomeIcons.penSquare;
      break;
    case 'externalLinkSquare':
      return FontAwesomeIcons.externalLinkSquareAlt;
      break;
    case 'shareSquare':
      return FontAwesomeIcons.shareSquare;
      break;
    case 'compass':
      return FontAwesomeIcons.compass;
      break;
    case 'alignLeft':
      return FontAwesomeIcons.alignLeft;
      break;
    case 'turkishLira':
      return FontAwesomeIcons.liraSign;
      break;
    case 'meanpath':
      return FontAwesomeIcons.fontAwesome;
      break;
    case 'try':
      return FontAwesomeIcons.liraSign;
      break;
    case 'caretSquareODown':
      return FontAwesomeIcons.solidCaretSquareDown;
      break;
    case 'toggleUp':
      return FontAwesomeIcons.toggleOn;
      break;
    case 'caretSquareOUp':
      return FontAwesomeIcons.solidCaretSquareUp;
      break;
    case 'toggleRight':
      return FontAwesomeIcons.question;
      break;
    case 'caretSquareORight':
      return FontAwesomeIcons.solidCaretSquareRight;
      break;
    case 'euro':
      return FontAwesomeIcons.euroSign;
      break;
    case 'eur':
      return FontAwesomeIcons.euroSign;
      break;
    case 'gbp':
      return FontAwesomeIcons.poundSign;
      break;
    case 'dollar':
      return FontAwesomeIcons.dollarSign;
      break;
    case 'usd':
      return FontAwesomeIcons.dollarSign;
      break;
    case 'rupee':
      return FontAwesomeIcons.rupeeSign;
      break;
    case 'inr':
      return FontAwesomeIcons.rupeeSign;
      break;
    case 'cny':
      return FontAwesomeIcons.yenSign;
      break;
    case 'rmb':
      return FontAwesomeIcons.yenSign;
      break;
    case 'yen':
      return FontAwesomeIcons.yenSign;
      break;
    case 'jpy':
      return FontAwesomeIcons.yenSign;
      break;
    case 'ruble':
      return FontAwesomeIcons.rubleSign;
      break;
    case 'rouble':
      return FontAwesomeIcons.rubleSign;
      break;
    case 'rub':
      return FontAwesomeIcons.rubleSign;
      break;
    case 'won':
      return FontAwesomeIcons.wonSign;
      break;
    case 'krw':
      return FontAwesomeIcons.wonSign;
      break;
    case 'bitcoin':
      return FontAwesomeIcons.bitcoin;
      break;
    case 'btc':
      return FontAwesomeIcons.btc;
      break;
    case 'file':
      return FontAwesomeIcons.file;
      break;
    case 'fileText':
      return FontAwesomeIcons.fileAlt;
      break;
    case 'sortAlphaAsc':
      return FontAwesomeIcons.sortAlphaDown;
      break;
    case 'sortAlphaDesc':
      return FontAwesomeIcons.sortAlphaUp;
      break;
    case 'sortAmountAsc':
      return FontAwesomeIcons.sortAmountDown;
      break;
    case 'sortAmountDesc':
      return FontAwesomeIcons.sortAmountUp;
      break;
    case 'sortNumericAsc':
      return FontAwesomeIcons.sortNumericDown;
      break;
    case 'sortNumericDesc':
      return FontAwesomeIcons.sortNumericUp;
      break;
    case 'thumbsUp':
      return FontAwesomeIcons.thumbsUp;
      break;
    case 'thumbsDown':
      return FontAwesomeIcons.thumbsDown;
      break;
    case 'youtubeSquare':
      return FontAwesomeIcons.youtubeSquare;
      break;
    case 'youtube':
      return FontAwesomeIcons.youtube;
      break;
    case 'xing':
      return FontAwesomeIcons.xing;
      break;
    case 'xingSquare':
      return FontAwesomeIcons.xingSquare;
      break;
    case 'youtubePlay':
      return FontAwesomeIcons.youtube;
      break;
    case 'dropbox':
      return FontAwesomeIcons.dropbox;
      break;
    case 'stackOverflow':
      return FontAwesomeIcons.stackOverflow;
      break;
    case 'instagram':
      return FontAwesomeIcons.instagram;
      break;
    case 'flickr':
      return FontAwesomeIcons.flickr;
      break;
    case 'adn':
      return FontAwesomeIcons.adn;
      break;
    case 'bitbucket':
      return FontAwesomeIcons.bitbucket;
      break;
    case 'bitbucketSquare':
      return FontAwesomeIcons.bitbucket;
      break;
    case 'tumblr':
      return FontAwesomeIcons.tumblr;
      break;
    case 'tumblrSquare':
      return FontAwesomeIcons.tumblrSquare;
      break;
    case 'longArrowDown':
      return FontAwesomeIcons.longArrowAltDown;
      break;
    case 'longArrowUp':
      return FontAwesomeIcons.longArrowAltUp;
      break;
    case 'longArrowLeft':
      return FontAwesomeIcons.longArrowAltLeft;
      break;
    case 'longArrowRight':
      return FontAwesomeIcons.longArrowAltRight;
      break;
    case 'apple':
      return FontAwesomeIcons.apple;
      break;
    case 'windows':
      return FontAwesomeIcons.windows;
      break;
    case 'android':
      return FontAwesomeIcons.android;
      break;
    case 'linux':
      return FontAwesomeIcons.linux;
      break;
    case 'dribbble':
      return FontAwesomeIcons.dribbble;
      break;
    case 'skype':
      return FontAwesomeIcons.skype;
      break;
    case 'foursquare':
      return FontAwesomeIcons.foursquare;
      break;
    case 'trello':
      return FontAwesomeIcons.trello;
      break;
    case 'female':
      return FontAwesomeIcons.female;
      break;
    case 'male':
      return FontAwesomeIcons.male;
      break;
    case 'gittip':
      return FontAwesomeIcons.gratipay;
      break;
    case 'gratipay':
      return FontAwesomeIcons.gratipay;
      break;
    case 'sunO':
      return FontAwesomeIcons.solidSun;
      break;
    case 'moonO':
      return FontAwesomeIcons.solidMoon;
      break;
    case 'archive':
      return FontAwesomeIcons.archive;
      break;
    case 'bug':
      return FontAwesomeIcons.bug;
      break;
    case 'vk':
      return FontAwesomeIcons.vk;
      break;
    case 'weibo':
      return FontAwesomeIcons.weibo;
      break;
    case 'renren':
      return FontAwesomeIcons.renren;
      break;
    case 'pagelines':
      return FontAwesomeIcons.pagelines;
      break;
    case 'stackExchange':
      return FontAwesomeIcons.stackExchange;
      break;
    case 'arrowCircleORight':
      return FontAwesomeIcons.solidArrowAltCircleRight;
      break;
    case 'arrowCircleOLeft':
      return FontAwesomeIcons.solidArrowAltCircleLeft;
      break;
    case 'caretSquareOLeft':
      return FontAwesomeIcons.solidCaretSquareLeft;
      break;
    case 'dotCircleO':
      return FontAwesomeIcons.solidDotCircle;
      break;
    case 'wheelchair':
      return FontAwesomeIcons.wheelchair;
      break;
    case 'vimeoSquare':
      return FontAwesomeIcons.vimeoSquare;
      break;
    case 'plusSquareO':
      return FontAwesomeIcons.solidPlusSquare;
      break;
    case 'spaceShuttle':
      return FontAwesomeIcons.spaceShuttle;
      break;
    case 'slack':
      return FontAwesomeIcons.slack;
      break;
    case 'envelopeSquare':
      return FontAwesomeIcons.envelopeSquare;
      break;
    case 'wordpress':
      return FontAwesomeIcons.wordpress;
      break;
    case 'openid':
      return FontAwesomeIcons.openid;
      break;
    case 'institution':
      return FontAwesomeIcons.university;
      break;
    case 'bank':
      return FontAwesomeIcons.university;
      break;
    case 'university':
      return FontAwesomeIcons.university;
      break;
    case 'mortarBoard':
      return FontAwesomeIcons.graduationCap;
      break;
    case 'graduationCap':
      return FontAwesomeIcons.graduationCap;
      break;
    case 'yahoo':
      return FontAwesomeIcons.yahoo;
      break;
    case 'google':
      return FontAwesomeIcons.google;
      break;
    case 'reddit':
      return FontAwesomeIcons.reddit;
      break;
    case 'redditSquare':
      return FontAwesomeIcons.redditSquare;
      break;
    case 'stumbleuponCircle':
      return FontAwesomeIcons.stumbleuponCircle;
      break;
    case 'stumbleupon':
      return FontAwesomeIcons.stumbleupon;
      break;
    case 'delicious':
      return FontAwesomeIcons.delicious;
      break;
    case 'digg':
      return FontAwesomeIcons.digg;
      break;
    case 'piedPiper':
      return FontAwesomeIcons.piedPiper;
      break;
    case 'piedPiperAlt':
      return FontAwesomeIcons.piedPiperAlt;
      break;
    case 'drupal':
      return FontAwesomeIcons.drupal;
      break;
    case 'joomla':
      return FontAwesomeIcons.joomla;
      break;
    case 'language':
      return FontAwesomeIcons.language;
      break;
    case 'fax':
      return FontAwesomeIcons.fax;
      break;
    case 'building':
      return FontAwesomeIcons.building;
      break;
    case 'child':
      return FontAwesomeIcons.child;
      break;
    case 'paw':
      return FontAwesomeIcons.paw;
      break;
    case 'spoon':
      return FontAwesomeIcons.utensilSpoon;
      break;
    case 'cube':
      return FontAwesomeIcons.cube;
      break;
    case 'cubes':
      return FontAwesomeIcons.cubes;
      break;
    case 'behance':
      return FontAwesomeIcons.behance;
      break;
    case 'behanceSquare':
      return FontAwesomeIcons.behanceSquare;
      break;
    case 'steam':
      return FontAwesomeIcons.steam;
      break;
    case 'steamSquare':
      return FontAwesomeIcons.steamSquare;
      break;
    case 'recycle':
      return FontAwesomeIcons.recycle;
      break;
    case 'automobile':
      return FontAwesomeIcons.car;
      break;
    case 'car':
      return FontAwesomeIcons.car;
      break;
    case 'cab':
      return FontAwesomeIcons.taxi;
      break;
    case 'taxi':
      return FontAwesomeIcons.taxi;
      break;
    case 'tree':
      return FontAwesomeIcons.tree;
      break;
    case 'spotify':
      return FontAwesomeIcons.spotify;
      break;
    case 'deviantart':
      return FontAwesomeIcons.deviantart;
      break;
    case 'soundcloud':
      return FontAwesomeIcons.soundcloud;
      break;
    case 'database':
      return FontAwesomeIcons.database;
      break;
    case 'filePdfO':
      return FontAwesomeIcons.solidFilePdf;
      break;
    case 'fileWordO':
      return FontAwesomeIcons.solidFileWord;
      break;
    case 'fileExcelO':
      return FontAwesomeIcons.solidFileExcel;
      break;
    case 'filePowerpointO':
      return FontAwesomeIcons.solidFilePowerpoint;
      break;
    case 'filePhotoO':
      return FontAwesomeIcons.solidFileImage;
      break;
    case 'filePictureO':
      return FontAwesomeIcons.solidFileImage;
      break;
    case 'fileImageO':
      return FontAwesomeIcons.solidFileImage;
      break;
    case 'fileZipO':
      return FontAwesomeIcons.fileArchive;
      break;
    case 'fileArchiveO':
      return FontAwesomeIcons.solidFileArchive;
      break;
    case 'fileSoundO':
      return FontAwesomeIcons.solidFileAudio;
      break;
    case 'fileAudioO':
      return FontAwesomeIcons.solidFileAudio;
      break;
    case 'fileMovieO':
      return FontAwesomeIcons.solidFileVideo;
      break;
    case 'fileVideoO':
      return FontAwesomeIcons.solidFileVideo;
      break;
    case 'fileCodeO':
      return FontAwesomeIcons.solidFileCode;
      break;
    case 'vine':
      return FontAwesomeIcons.vine;
      break;
    case 'codepen':
      return FontAwesomeIcons.codepen;
      break;
    case 'jsfiddle':
      return FontAwesomeIcons.jsfiddle;
      break;
    case 'lifeBouy':
      return FontAwesomeIcons.lifeRing;
      break;
    case 'lifeBuoy':
      return FontAwesomeIcons.lifeRing;
      break;
    case 'lifeSaver':
      return FontAwesomeIcons.lifeRing;
      break;
    case 'support':
      return FontAwesomeIcons.phoneSquare;
      break;
    case 'lifeRing':
      return FontAwesomeIcons.lifeRing;
      break;
    case 'circleONotch':
      return FontAwesomeIcons.circleNotch;
      break;
    case 'ra':
      return FontAwesomeIcons.rebel;
      break;
    case 'rebel':
      return FontAwesomeIcons.rebel;
      break;
    case 'ge':
      return FontAwesomeIcons.empire;
      break;
    case 'empire':
      return FontAwesomeIcons.empire;
      break;
    case 'gitSquare':
      return FontAwesomeIcons.gitSquare;
      break;
    case 'git':
      return FontAwesomeIcons.git;
      break;
    case 'yCombinatorSquare':
      return FontAwesomeIcons.yCombinator;
      break;
    case 'ycSquare':
      return FontAwesomeIcons.hackerNewsSquare;
      break;
    case 'hackerNews':
      return FontAwesomeIcons.hackerNews;
      break;
    case 'tencentWeibo':
      return FontAwesomeIcons.tencentWeibo;
      break;
    case 'qq':
      return FontAwesomeIcons.qq;
      break;
    case 'wechat':
      return FontAwesomeIcons.weixin;
      break;
    case 'weixin':
      return FontAwesomeIcons.weixin;
      break;
    case 'send':
      return FontAwesomeIcons.solidShareSquare;
      break;
    case 'paperPlane':
      return FontAwesomeIcons.paperPlane;
      break;
    case 'sendO':
      return FontAwesomeIcons.shareSquare;
      break;
    case 'paperPlaneO':
      return FontAwesomeIcons.solidPaperPlane;
      break;
    case 'history':
      return FontAwesomeIcons.history;
      break;
    case 'circleThin':
      return FontAwesomeIcons.circle;
      break;
    case 'header':
      return FontAwesomeIcons.heading;
      break;
    case 'paragraph':
      return FontAwesomeIcons.paragraph;
      break;
    case 'sliders':
      return FontAwesomeIcons.slidersH;
      break;
    case 'shareAlt':
      return FontAwesomeIcons.shareAlt;
      break;
    case 'shareAltSquare':
      return FontAwesomeIcons.shareAltSquare;
      break;
    case 'bomb':
      return FontAwesomeIcons.bomb;
      break;
    case 'soccerBallO':
      return FontAwesomeIcons.solidFutbol;
      break;
    case 'futbolO':
      return FontAwesomeIcons.solidFutbol;
      break;
    case 'tty':
      return FontAwesomeIcons.tty;
      break;
    case 'binoculars':
      return FontAwesomeIcons.binoculars;
      break;
    case 'plug':
      return FontAwesomeIcons.plug;
      break;
    case 'slideshare':
      return FontAwesomeIcons.slideshare;
      break;
    case 'twitch':
      return FontAwesomeIcons.twitch;
      break;
    case 'yelp':
      return FontAwesomeIcons.yelp;
      break;
    case 'newspaperO':
      return FontAwesomeIcons.solidNewspaper;
      break;
    case 'wifi':
      return FontAwesomeIcons.wifi;
      break;
    case 'calculator':
      return FontAwesomeIcons.calculator;
      break;
    case 'paypal':
      return FontAwesomeIcons.paypal;
      break;
    case 'googleWallet':
      return FontAwesomeIcons.googleWallet;
      break;
    case 'ccVisa':
      return FontAwesomeIcons.ccVisa;
      break;
    case 'ccMastercard':
      return FontAwesomeIcons.ccMastercard;
      break;
    case 'ccDiscover':
      return FontAwesomeIcons.ccDiscover;
      break;
    case 'ccAmex':
      return FontAwesomeIcons.ccAmex;
      break;
    case 'ccPaypal':
      return FontAwesomeIcons.ccPaypal;
      break;
    case 'ccStripe':
      return FontAwesomeIcons.ccStripe;
      break;
    case 'bellSlash':
      return FontAwesomeIcons.bellSlash;
      break;
    case 'bellSlashO':
      return FontAwesomeIcons.solidBellSlash;
      break;
    case 'trash':
      return FontAwesomeIcons.trash;
      break;
    case 'copyright':
      return FontAwesomeIcons.copyright;
      break;
    case 'at':
      return FontAwesomeIcons.at;
      break;
    case 'eyedropper':
      return FontAwesomeIcons.eyeDropper;
      break;
    case 'paintBrush':
      return FontAwesomeIcons.paintBrush;
      break;
    case 'birthdayCake':
      return FontAwesomeIcons.birthdayCake;
      break;
    case 'areaChart':
      return FontAwesomeIcons.chartArea;
      break;
    case 'pieChart':
      return FontAwesomeIcons.chartPie;
      break;
    case 'lineChart':
      return FontAwesomeIcons.chartLine;
      break;
    case 'lastfm':
      return FontAwesomeIcons.lastfm;
      break;
    case 'lastfmSquare':
      return FontAwesomeIcons.lastfmSquare;
      break;
    case 'toggleOff':
      return FontAwesomeIcons.toggleOff;
      break;
    case 'toggleOn':
      return FontAwesomeIcons.toggleOn;
      break;
    case 'bicycle':
      return FontAwesomeIcons.bicycle;
      break;
    case 'bus':
      return FontAwesomeIcons.bus;
      break;
    case 'ioxhost':
      return FontAwesomeIcons.ioxhost;
      break;
    case 'angellist':
      return FontAwesomeIcons.angellist;
      break;
    case 'cc':
      return FontAwesomeIcons.closedCaptioning;
      break;
    case 'shekel':
      return FontAwesomeIcons.shekelSign;
      break;
    case 'sheqel':
      return FontAwesomeIcons.shekelSign;
      break;
    case 'ils':
      return FontAwesomeIcons.shekelSign;
      break;
    case 'buysellads':
      return FontAwesomeIcons.buysellads;
      break;
    case 'connectdevelop':
      return FontAwesomeIcons.connectdevelop;
      break;
    case 'dashcube':
      return FontAwesomeIcons.dashcube;
      break;
    case 'forumbee':
      return FontAwesomeIcons.forumbee;
      break;
    case 'leanpub':
      return FontAwesomeIcons.leanpub;
      break;
    case 'sellsy':
      return FontAwesomeIcons.sellsy;
      break;
    case 'shirtsinbulk':
      return FontAwesomeIcons.shirtsinbulk;
      break;
    case 'simplybuilt':
      return FontAwesomeIcons.simplybuilt;
      break;
    case 'skyatlas':
      return FontAwesomeIcons.skyatlas;
      break;
    case 'cartPlus':
      return FontAwesomeIcons.cartPlus;
      break;
    case 'cartArrowDown':
      return FontAwesomeIcons.cartArrowDown;
      break;
    case 'diamond':
      return FontAwesomeIcons.gem;
      break;
    case 'ship':
      return FontAwesomeIcons.ship;
      break;
    case 'userSecret':
      return FontAwesomeIcons.userSecret;
      break;
    case 'motorcycle':
      return FontAwesomeIcons.motorcycle;
      break;
    case 'streetView':
      return FontAwesomeIcons.streetView;
      break;
    case 'heartbeat':
      return FontAwesomeIcons.heartbeat;
      break;
    case 'venus':
      return FontAwesomeIcons.venus;
      break;
    case 'mars':
      return FontAwesomeIcons.mars;
      break;
    case 'mercury':
      return FontAwesomeIcons.mercury;
      break;
    case 'intersex':
      return FontAwesomeIcons.transgender;
      break;
    case 'transgender':
      return FontAwesomeIcons.transgender;
      break;
    case 'transgenderAlt':
      return FontAwesomeIcons.transgenderAlt;
      break;
    case 'venusDouble':
      return FontAwesomeIcons.venusDouble;
      break;
    case 'marsDouble':
      return FontAwesomeIcons.marsDouble;
      break;
    case 'venusMars':
      return FontAwesomeIcons.venusMars;
      break;
    case 'marsStroke':
      return FontAwesomeIcons.marsStroke;
      break;
    case 'marsStrokeV':
      return FontAwesomeIcons.marsStrokeV;
      break;
    case 'marsStrokeH':
      return FontAwesomeIcons.marsStrokeH;
      break;
    case 'neuter':
      return FontAwesomeIcons.neuter;
      break;
    case 'genderless':
      return FontAwesomeIcons.genderless;
      break;
    case 'facebookOfficial':
      return FontAwesomeIcons.facebook;
      break;
    case 'pinterestP':
      return FontAwesomeIcons.pinterestP;
      break;
    case 'whatsapp':
      return FontAwesomeIcons.whatsapp;
      break;
    case 'server':
      return FontAwesomeIcons.server;
      break;
    case 'userPlus':
      return FontAwesomeIcons.userPlus;
      break;
    case 'userTimes':
      return FontAwesomeIcons.userTimes;
      break;
    case 'hotel':
      return FontAwesomeIcons.hotel;
      break;
    case 'bed':
      return FontAwesomeIcons.bed;
      break;
    case 'viacoin':
      return FontAwesomeIcons.viacoin;
      break;
    case 'train':
      return FontAwesomeIcons.train;
      break;
    case 'subway':
      return FontAwesomeIcons.subway;
      break;
    case 'medium':
      return FontAwesomeIcons.medium;
      break;
    case 'yc':
      return FontAwesomeIcons.yCombinator;
      break;
    case 'yCombinator':
      return FontAwesomeIcons.yCombinator;
      break;
    case 'optinMonster':
      return FontAwesomeIcons.optinMonster;
      break;
    case 'opencart':
      return FontAwesomeIcons.opencart;
      break;
    case 'expeditedssl':
      return FontAwesomeIcons.expeditedssl;
      break;
    case 'battery4':
      return FontAwesomeIcons.batteryFull;
      break;
    case 'batteryFull':
      return FontAwesomeIcons.batteryFull;
      break;
    case 'battery3':
      return FontAwesomeIcons.batteryThreeQuarters;
      break;
    case 'batteryThreeQuarters':
      return FontAwesomeIcons.batteryThreeQuarters;
      break;
    case 'battery2':
      return FontAwesomeIcons.batteryHalf;
      break;
    case 'batteryHalf':
      return FontAwesomeIcons.batteryHalf;
      break;
    case 'battery1':
      return FontAwesomeIcons.batteryQuarter;
      break;
    case 'batteryQuarter':
      return FontAwesomeIcons.batteryQuarter;
      break;
    case 'battery0':
      return FontAwesomeIcons.batteryEmpty;
      break;
    case 'batteryEmpty':
      return FontAwesomeIcons.batteryEmpty;
      break;
    case 'mousePointer':
      return FontAwesomeIcons.mousePointer;
      break;
    case 'iCursor':
      return FontAwesomeIcons.iCursor;
      break;
    case 'objectGroup':
      return FontAwesomeIcons.objectGroup;
      break;
    case 'objectUngroup':
      return FontAwesomeIcons.objectUngroup;
      break;
    case 'stickyNote':
      return FontAwesomeIcons.stickyNote;
      break;
    case 'stickyNoteO':
      return FontAwesomeIcons.stickyNote;
      break;
    case 'ccJcb':
      return FontAwesomeIcons.ccJcb;
      break;
    case 'ccDinersClub':
      return FontAwesomeIcons.ccDinersClub;
      break;
    case 'clone':
      return FontAwesomeIcons.clone;
      break;
    case 'balanceScale':
      return FontAwesomeIcons.balanceScale;
      break;
    case 'hourglassO':
      return FontAwesomeIcons.hourglass;
      break;
    case 'hourglass1':
      return FontAwesomeIcons.hourglassStart;
      break;
    case 'hourglassStart':
      return FontAwesomeIcons.hourglassStart;
      break;
    case 'hourglass2':
      return FontAwesomeIcons.hourglassHalf;
      break;
    case 'hourglassHalf':
      return FontAwesomeIcons.hourglassHalf;
      break;
    case 'hourglass3':
      return FontAwesomeIcons.hourglassEnd;
      break;
    case 'hourglassEnd':
      return FontAwesomeIcons.hourglassEnd;
      break;
    case 'hourglass':
      return FontAwesomeIcons.hourglass;
      break;
    case 'handGrabO':
      return FontAwesomeIcons.solidHandRock;
      break;
    case 'handRockO':
      return FontAwesomeIcons.solidHandRock;
      break;
    case 'handStopO':
      return FontAwesomeIcons.solidHandPaper;
      break;
    case 'handPaperO':
      return FontAwesomeIcons.solidHandPaper;
      break;
    case 'handScissorsO':
      return FontAwesomeIcons.solidHandScissors;
      break;
    case 'handLizardO':
      return FontAwesomeIcons.solidHandLizard;
      break;
    case 'handSpockO':
      return FontAwesomeIcons.solidHandSpock;
      break;
    case 'handPointerO':
      return FontAwesomeIcons.solidHandPointer;
      break;
    case 'handPeaceO':
      return FontAwesomeIcons.solidHandPeace;
      break;
    case 'trademark':
      return FontAwesomeIcons.trademark;
      break;
    case 'registered':
      return FontAwesomeIcons.registered;
      break;
    case 'creativeCommons':
      return FontAwesomeIcons.creativeCommons;
      break;
    case 'gg':
      return FontAwesomeIcons.gg;
      break;
    case 'ggCircle':
      return FontAwesomeIcons.ggCircle;
      break;
    case 'tripadvisor':
      return FontAwesomeIcons.tripadvisor;
      break;
    case 'odnoklassniki':
      return FontAwesomeIcons.odnoklassniki;
      break;
    case 'odnoklassnikiSquare':
      return FontAwesomeIcons.odnoklassnikiSquare;
      break;
    case 'getPocket':
      return FontAwesomeIcons.getPocket;
      break;
    case 'wikipediaW':
      return FontAwesomeIcons.wikipediaW;
      break;
    case 'safari':
      return FontAwesomeIcons.safari;
      break;
    case 'chrome':
      return FontAwesomeIcons.chrome;
      break;
    case 'firefox':
      return FontAwesomeIcons.firefox;
      break;
    case 'opera':
      return FontAwesomeIcons.opera;
      break;
    case 'internetExplorer':
      return FontAwesomeIcons.internetExplorer;
      break;
    case 'tv':
      return FontAwesomeIcons.tv;
      break;
    case 'television':
      return FontAwesomeIcons.tv;
      break;
    case 'contao':
      return FontAwesomeIcons.contao;
      break;
    case 'px':
      return FontAwesomeIcons.fiveHundredPx;
      break;
    case 'amazon':
      return FontAwesomeIcons.amazon;
      break;
    case 'calendarPlusO':
      return FontAwesomeIcons.solidCalendarPlus;
      break;
    case 'calendarMinusO':
      return FontAwesomeIcons.solidCalendarMinus;
      break;
    case 'calendarTimesO':
      return FontAwesomeIcons.solidCalendarTimes;
      break;
    case 'calendarCheckO':
      return FontAwesomeIcons.solidCalendarCheck;
      break;
    case 'industry':
      return FontAwesomeIcons.industry;
      break;
    case 'mapPin':
      return FontAwesomeIcons.mapPin;
      break;
    case 'mapSigns':
      return FontAwesomeIcons.mapSigns;
      break;
    case 'mapO':
      return FontAwesomeIcons.solidMap;
      break;
    case 'map':
      return FontAwesomeIcons.map;
      break;
    case 'commenting':
      return FontAwesomeIcons.commentDots;
      break;
    case 'commentingO':
      return FontAwesomeIcons.solidCommentDots;
      break;
    case 'houzz':
      return FontAwesomeIcons.houzz;
      break;
    case 'vimeo':
      return FontAwesomeIcons.vimeo;
      break;
    case 'blackTie':
      return FontAwesomeIcons.blackTie;
      break;
    case 'fonticons':
      return FontAwesomeIcons.fonticons;
      break;
    default:
      return FontAwesomeIcons.questionCircle;
      break;
  }
}