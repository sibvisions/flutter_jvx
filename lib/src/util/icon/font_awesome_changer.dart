import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

bool checkFontAwesome(String text) {
  if (text.contains('FontAwesome')) {
    return true;
  }
  return false;
}

formatFontAwesomeText(String text) {
  if (!checkFontAwesome(text)) return "This is no fontawesome string";

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

convertFontAwesomeTextToIcon(String text, Color color) {
  if (!checkFontAwesome(text)) return "This is no fontawesome string";

  List<String> arr = text.split(',');

  String icon = arr[0];
  Size size = Size(16, 16);

  if (arr.length >= 3 &&
      double.tryParse(arr[1]) != null &&
      double.tryParse(arr[2]) != null)
    size = Size(double.parse(arr[1]), double.parse(arr[2]));

  if (icon.contains(";")) {
    icon = icon.substring(0, icon.indexOf(";"));
  }

  return new FaIcon(
    chooseIcon(convertToMethodName(icon)),
    size: size.width,
    color: color,
  );
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

    case 'music':
      return FontAwesomeIcons.music;

    case 'search':
      return FontAwesomeIcons.search;

    case 'envelopeO':
      return FontAwesomeIcons.solidEnvelope;

    case 'heart':
      return FontAwesomeIcons.heart;

    case 'star':
      return FontAwesomeIcons.star;

    case 'starO':
      return FontAwesomeIcons.solidStar;

    case 'user':
      return FontAwesomeIcons.user;

    case 'film':
      return FontAwesomeIcons.film;

    case 'thLarge':
      return FontAwesomeIcons.thLarge;

    case 'th':
      return FontAwesomeIcons.th;

    case 'thList':
      return FontAwesomeIcons.thList;

    case 'check':
      return FontAwesomeIcons.check;

    case 'remove':
      return FontAwesomeIcons.trashAlt;

    case 'close':
      return FontAwesomeIcons.times;

    case 'times':
      return FontAwesomeIcons.times;

    case 'searchPlus':
      return FontAwesomeIcons.searchPlus;

    case 'searchMinus':
      return FontAwesomeIcons.searchMinus;

    case 'powerOff':
      return FontAwesomeIcons.powerOff;

    case 'signal':
      return FontAwesomeIcons.signal;

    case 'gear':
      return FontAwesomeIcons.cogs;

    case 'cog':
      return FontAwesomeIcons.cog;

    case 'trashO':
      return FontAwesomeIcons.solidTrashAlt;

    case 'home':
      return FontAwesomeIcons.home;

    case 'fileO':
      return FontAwesomeIcons.solidFile;

    case 'clockO':
      return FontAwesomeIcons.solidClock;

    case 'road':
      return FontAwesomeIcons.road;

    case 'download':
      return FontAwesomeIcons.download;

    case 'arrowCircleODown':
      return FontAwesomeIcons.solidArrowAltCircleDown;

    case 'arrowCircleOUp':
      return FontAwesomeIcons.solidArrowAltCircleUp;

    case 'inbox':
      return FontAwesomeIcons.inbox;

    case 'playCircleO':
      return FontAwesomeIcons.solidPlayCircle;

    case 'rotateRight':
      return FontAwesomeIcons.sync;

    case 'repeat':
      return FontAwesomeIcons.redoAlt;

    case 'refresh':
      return FontAwesomeIcons.redo;

    case 'listAlt':
      return FontAwesomeIcons.listAlt;

    case 'lock':
      return FontAwesomeIcons.lock;

    case 'flag':
      return FontAwesomeIcons.flag;

    case 'headphones':
      return FontAwesomeIcons.headphones;

    case 'volumeOff':
      return FontAwesomeIcons.volumeOff;

    case 'volumeDown':
      return FontAwesomeIcons.volumeDown;

    case 'volumeUp':
      return FontAwesomeIcons.volumeUp;

    case 'qrcode':
      return FontAwesomeIcons.qrcode;

    case 'barcode':
      return FontAwesomeIcons.barcode;

    case 'tag':
      return FontAwesomeIcons.tag;

    case 'tags':
      return FontAwesomeIcons.tags;

    case 'book':
      return FontAwesomeIcons.book;

    case 'bookmark':
      return FontAwesomeIcons.bookmark;

    case 'print':
      return FontAwesomeIcons.print;

    case 'camera':
      return FontAwesomeIcons.camera;

    case 'font':
      return FontAwesomeIcons.font;

    case 'bold':
      return FontAwesomeIcons.bold;

    case 'italic':
      return FontAwesomeIcons.italic;

    case 'textHeight':
      return FontAwesomeIcons.textHeight;

    case 'textWidth':
      return FontAwesomeIcons.textWidth;

    case 'alignLeft':
      return FontAwesomeIcons.alignLeft;

    case 'alignCenter':
      return FontAwesomeIcons.alignCenter;

    case 'alignRight':
      return FontAwesomeIcons.alignRight;

    case 'alignJustify':
      return FontAwesomeIcons.alignJustify;

    case 'list':
      return FontAwesomeIcons.list;

    case 'dedent':
      return FontAwesomeIcons.outdent;

    case 'outdent':
      return FontAwesomeIcons.outdent;

    case 'indent':
      return FontAwesomeIcons.indent;

    case 'videoCamera':
      return FontAwesomeIcons.video;

    case 'photo':
      return FontAwesomeIcons.image;

    case 'image':
      return FontAwesomeIcons.image;

    case 'pictureO':
      return FontAwesomeIcons.solidImage;

    case 'pencil':
      return FontAwesomeIcons.pencilAlt;

    case 'mapMarker':
      return FontAwesomeIcons.mapMarker;

    case 'adjust':
      return FontAwesomeIcons.adjust;

    case 'tint':
      return FontAwesomeIcons.tint;

    case 'edit':
      return FontAwesomeIcons.edit;

    case 'pencilSquareO':
      return FontAwesomeIcons.penSquare;

    case 'shareSquareO':
      return FontAwesomeIcons.solidShareSquare;

    case 'checkSquareO':
      return FontAwesomeIcons.solidCheckSquare;

    case 'arrows':
      return FontAwesomeIcons.arrowsAlt;

    case 'stepBackward':
      return FontAwesomeIcons.stepBackward;

    case 'fastBackward':
      return FontAwesomeIcons.fastBackward;

    case 'backward':
      return FontAwesomeIcons.backward;

    case 'play':
      return FontAwesomeIcons.play;

    case 'pause':
      return FontAwesomeIcons.pause;

    case 'stop':
      return FontAwesomeIcons.stop;

    case 'forward':
      return FontAwesomeIcons.forward;

    case 'fastForward':
      return FontAwesomeIcons.fastForward;

    case 'stepForward':
      return FontAwesomeIcons.stepForward;

    case 'eject':
      return FontAwesomeIcons.eject;

    case 'chevronLeft':
      return FontAwesomeIcons.chevronLeft;

    case 'chevronRight':
      return FontAwesomeIcons.chevronRight;

    case 'plusCircle':
      return FontAwesomeIcons.plusCircle;

    case 'minusCircle':
      return FontAwesomeIcons.minusCircle;

    case 'timesCircle':
      return FontAwesomeIcons.timesCircle;

    case 'checkCircle':
      return FontAwesomeIcons.checkCircle;

    case 'questionCircle':
      return FontAwesomeIcons.questionCircle;

    case 'infoCircle':
      return FontAwesomeIcons.infoCircle;

    case 'crosshairs':
      return FontAwesomeIcons.crosshairs;

    case 'timesCircleO':
      return FontAwesomeIcons.solidTimesCircle;

    case 'checkCircleO':
      return FontAwesomeIcons.solidCheckCircle;

    case 'ban':
      return FontAwesomeIcons.ban;

    case 'arrowLeft':
      return FontAwesomeIcons.arrowLeft;

    case 'arrowRight':
      return FontAwesomeIcons.arrowRight;

    case 'arrowUp':
      return FontAwesomeIcons.arrowUp;

    case 'arrowDown':
      return FontAwesomeIcons.arrowDown;

    case 'mailForward':
      return FontAwesomeIcons.share;

    case 'share':
      return FontAwesomeIcons.share;

    case 'expand':
      return FontAwesomeIcons.expand;

    case 'compress':
      return FontAwesomeIcons.compress;

    case 'plus':
      return FontAwesomeIcons.plus;

    case 'minus':
      return FontAwesomeIcons.minus;

    case 'asterisk':
      return FontAwesomeIcons.asterisk;

    case 'exclamationCircle':
      return FontAwesomeIcons.exclamationCircle;

    case 'gift':
      return FontAwesomeIcons.gift;

    case 'leaf':
      return FontAwesomeIcons.leaf;

    case 'fire':
      return FontAwesomeIcons.fire;

    case 'eye':
      return FontAwesomeIcons.eye;

    case 'eyeSlash':
      return FontAwesomeIcons.eyeSlash;

    case 'warning':
      return FontAwesomeIcons.exclamation;

    case 'exclamationTriangle':
      return FontAwesomeIcons.exclamationTriangle;

    case 'plane':
      return FontAwesomeIcons.plane;

    case 'calendar':
      return FontAwesomeIcons.calendar;

    case 'random':
      return FontAwesomeIcons.random;

    case 'comment':
      return FontAwesomeIcons.comment;

    case 'magnet':
      return FontAwesomeIcons.magnet;

    case 'chevronUp':
      return FontAwesomeIcons.chevronUp;

    case 'chevronDown':
      return FontAwesomeIcons.chevronDown;

    case 'retweet':
      return FontAwesomeIcons.retweet;

    case 'shoppingCart':
      return FontAwesomeIcons.shoppingCart;

    case 'folder':
      return FontAwesomeIcons.folder;

    case 'folderOpen':
      return FontAwesomeIcons.folderOpen;

    case 'arrowsV':
      return FontAwesomeIcons.arrowsAltV;

    case 'arrowsH':
      return FontAwesomeIcons.arrowsAltH;

    case 'barChartO':
      return FontAwesomeIcons.solidChartBar;

    case 'barChart':
      return FontAwesomeIcons.chartBar;

    case 'twitterSquare':
      return FontAwesomeIcons.twitterSquare;

    case 'facebookSquare':
      return FontAwesomeIcons.facebookSquare;

    case 'cameraRetro':
      return FontAwesomeIcons.cameraRetro;

    case 'key':
      return FontAwesomeIcons.key;

    case 'gears':
      return FontAwesomeIcons.cogs;

    case 'cogs':
      return FontAwesomeIcons.cogs;

    case 'comments':
      return FontAwesomeIcons.comments;

    case 'thumbsOUp':
      return FontAwesomeIcons.solidThumbsUp;

    case 'thumbsODown':
      return FontAwesomeIcons.solidThumbsDown;

    case 'starHalf':
      return FontAwesomeIcons.starHalf;

    case 'heartO':
      return FontAwesomeIcons.solidHeart;

    case 'signOut':
      return FontAwesomeIcons.signOutAlt;

    case 'linkedinSquare':
      return FontAwesomeIcons.linkedin;

    case 'thumbTack':
      return FontAwesomeIcons.thumbtack;

    case 'externalLink':
      return FontAwesomeIcons.externalLinkAlt;

    case 'signIn':
      return FontAwesomeIcons.signInAlt;

    case 'trophy':
      return FontAwesomeIcons.trophy;

    case 'githubSquare':
      return FontAwesomeIcons.githubSquare;

    case 'upload':
      return FontAwesomeIcons.upload;

    case 'lemonO':
      return FontAwesomeIcons.solidLemon;

    case 'phone':
      return FontAwesomeIcons.phone;

    case 'squareO':
      return FontAwesomeIcons.solidSquare;

    case 'bookmarkO':
      return FontAwesomeIcons.solidBookmark;

    case 'phoneSquare':
      return FontAwesomeIcons.phoneSquare;

    case 'twitter':
      return FontAwesomeIcons.twitter;

    case 'facebookF':
      return FontAwesomeIcons.facebookF;

    case 'facebook':
      return FontAwesomeIcons.facebook;

    case 'github':
      return FontAwesomeIcons.github;

    case 'unlock':
      return FontAwesomeIcons.unlock;

    case 'creditCard':
      return FontAwesomeIcons.creditCard;

    case 'feed':
      return FontAwesomeIcons.rss;

    case 'rss':
      return FontAwesomeIcons.rss;

    case 'hddO':
      return FontAwesomeIcons.solidHdd;

    case 'bullhorn':
      return FontAwesomeIcons.bullhorn;

    case 'bell':
      return FontAwesomeIcons.bell;

    case 'certificate':
      return FontAwesomeIcons.certificate;

    case 'handORight':
      return FontAwesomeIcons.solidHandPointRight;

    case 'handOLeft':
      return FontAwesomeIcons.solidHandPointLeft;

    case 'handOUp':
      return FontAwesomeIcons.solidHandPointUp;

    case 'handODown':
      return FontAwesomeIcons.solidHandPointDown;

    case 'arrowCircleLeft':
      return FontAwesomeIcons.arrowCircleLeft;

    case 'arrowCircleRight':
      return FontAwesomeIcons.arrowCircleRight;

    case 'arrowCircleUp':
      return FontAwesomeIcons.arrowCircleUp;

    case 'arrowCircleDown':
      return FontAwesomeIcons.arrowCircleDown;

    case 'globe':
      return FontAwesomeIcons.globe;

    case 'wrench':
      return FontAwesomeIcons.wrench;

    case 'tasks':
      return FontAwesomeIcons.tasks;

    case 'filter':
      return FontAwesomeIcons.filter;

    case 'briefcase':
      return FontAwesomeIcons.briefcase;

    case 'arrowsAlt':
      return FontAwesomeIcons.arrowsAlt;

    case 'group':
      return FontAwesomeIcons.users;

    case 'users':
      return FontAwesomeIcons.users;

    case 'chain':
      return FontAwesomeIcons.link;

    case 'link':
      return FontAwesomeIcons.link;

    case 'cloud':
      return FontAwesomeIcons.cloud;

    case 'flask':
      return FontAwesomeIcons.flask;

    case 'cut':
      return FontAwesomeIcons.cut;

    case 'scissors':
      return FontAwesomeIcons.cut;

    case 'copy':
      return FontAwesomeIcons.copy;

    case 'filesO':
      return FontAwesomeIcons.solidFile;

    case 'paperclip':
      return FontAwesomeIcons.paperclip;

    case 'save':
      return FontAwesomeIcons.save;

    case 'floppyO':
      return FontAwesomeIcons.save;

    case 'square':
      return FontAwesomeIcons.square;

    case 'navicon':
      return FontAwesomeIcons.bars;

    case 'reorder':
      return FontAwesomeIcons.bars;

    case 'bars':
      return FontAwesomeIcons.bars;

    case 'listUl':
      return FontAwesomeIcons.listUl;

    case 'listOl':
      return FontAwesomeIcons.listOl;

    case 'strikethrough':
      return FontAwesomeIcons.strikethrough;

    case 'underline':
      return FontAwesomeIcons.underline;

    case 'table':
      return FontAwesomeIcons.table;

    case 'magic':
      return FontAwesomeIcons.magic;

    case 'truck':
      return FontAwesomeIcons.truck;

    case 'pinterest':
      return FontAwesomeIcons.pinterest;

    case 'pinterestSquare':
      return FontAwesomeIcons.pinterestSquare;

    case 'googlePlusSquare':
      return FontAwesomeIcons.googlePlusSquare;

    case 'googlePlus':
      return FontAwesomeIcons.googlePlus;

    case 'money':
      return FontAwesomeIcons.moneyBill;

    case 'caretDown':
      return FontAwesomeIcons.caretDown;

    case 'caretUp':
      return FontAwesomeIcons.caretUp;

    case 'caretLeft':
      return FontAwesomeIcons.caretLeft;

    case 'caretRight':
      return FontAwesomeIcons.caretRight;

    case 'columns':
      return FontAwesomeIcons.columns;

    case 'unsorted':
      return FontAwesomeIcons.sort;

    case 'sort':
      return FontAwesomeIcons.sort;

    case 'sortDown':
      return FontAwesomeIcons.sortDown;

    case 'sortDesc':
      return FontAwesomeIcons.sortNumericDown;

    case 'sortUp':
      return FontAwesomeIcons.sortUp;

    case 'sortAsc':
      return FontAwesomeIcons.sortNumericUp;

    case 'envelope':
      return FontAwesomeIcons.envelope;

    case 'linkedin':
      return FontAwesomeIcons.linkedin;

    case 'rotateLeft':
      return FontAwesomeIcons.undo;

    case 'undo':
      return FontAwesomeIcons.undo;

    case 'legal':
      return FontAwesomeIcons.gavel;

    case 'gavel':
      return FontAwesomeIcons.gavel;

    case 'dashboard':
      return FontAwesomeIcons.tachometerAlt;

    case 'tachometer':
      return FontAwesomeIcons.tachometerAlt;

    case 'commentO':
      return FontAwesomeIcons.solidComment;

    case 'commentsO':
      return FontAwesomeIcons.solidComments;

    case 'flash':
      return FontAwesomeIcons.bolt;

    case 'bolt':
      return FontAwesomeIcons.bolt;

    case 'sitemap':
      return FontAwesomeIcons.sitemap;

    case 'umbrella':
      return FontAwesomeIcons.umbrella;

    case 'paste':
      return FontAwesomeIcons.paste;

    case 'clipboard':
      return FontAwesomeIcons.clipboard;

    case 'lightbulbO':
      return FontAwesomeIcons.solidLightbulb;

    case 'exchange':
      return FontAwesomeIcons.exchangeAlt;

    case 'cloudDownload':
      return FontAwesomeIcons.cloudDownloadAlt;

    case 'cloudUpload':
      return FontAwesomeIcons.cloudUploadAlt;

    case 'userMd':
      return FontAwesomeIcons.userMd;

    case 'stethoscope':
      return FontAwesomeIcons.stethoscope;

    case 'suitcase':
      return FontAwesomeIcons.suitcase;

    case 'bellO':
      return FontAwesomeIcons.solidBell;

    case 'coffee':
      return FontAwesomeIcons.coffee;

    case 'cutlery':
      return FontAwesomeIcons.utensils;

    case 'fileTextO':
      return FontAwesomeIcons.solidFileAlt;

    case 'buildingO':
      return FontAwesomeIcons.solidBuilding;

    case 'hospitalO':
      return FontAwesomeIcons.solidHospital;

    case 'ambulance':
      return FontAwesomeIcons.ambulance;

    case 'medkit':
      return FontAwesomeIcons.medkit;

    case 'fighterJet':
      return FontAwesomeIcons.fighterJet;

    case 'beer':
      return FontAwesomeIcons.beer;

    case 'hSquare':
      return FontAwesomeIcons.hSquare;

    case 'plusSquare':
      return FontAwesomeIcons.plusSquare;

    case 'angleDoubleLeft':
      return FontAwesomeIcons.angleDoubleLeft;

    case 'angleDoubleRight':
      return FontAwesomeIcons.angleDoubleRight;

    case 'angleDoubleUp':
      return FontAwesomeIcons.angleDoubleUp;

    case 'angleDoubleDown':
      return FontAwesomeIcons.angleDoubleDown;

    case 'angleLeft':
      return FontAwesomeIcons.angleLeft;

    case 'angleRight':
      return FontAwesomeIcons.angleRight;

    case 'angleUp':
      return FontAwesomeIcons.angleUp;

    case 'angleDown':
      return FontAwesomeIcons.angleDown;

    case 'desktop':
      return FontAwesomeIcons.desktop;

    case 'laptop':
      return FontAwesomeIcons.laptop;

    case 'tablet':
      return FontAwesomeIcons.tablet;

    case 'mobilePhone':
      return FontAwesomeIcons.mobileAlt;

    case 'mobile':
      return FontAwesomeIcons.mobile;

    case 'circleO':
      return FontAwesomeIcons.solidCircle;

    case 'quoteLeft':
      return FontAwesomeIcons.quoteLeft;

    case 'quoteRight':
      return FontAwesomeIcons.quoteRight;

    case 'spinner':
      return FontAwesomeIcons.spinner;

    case 'circle':
      return FontAwesomeIcons.circle;

    case 'mailReply':
      return FontAwesomeIcons.reply;

    case 'reply':
      return FontAwesomeIcons.reply;

    case 'githubAlt':
      return FontAwesomeIcons.githubAlt;

    case 'folderO':
      return FontAwesomeIcons.solidFolder;

    case 'folderOpenO':
      return FontAwesomeIcons.solidFolderOpen;

    case 'smileO':
      return FontAwesomeIcons.solidSmile;

    case 'frownO':
      return FontAwesomeIcons.solidFrown;

    case 'mehO':
      return FontAwesomeIcons.solidMeh;

    case 'gamepad':
      return FontAwesomeIcons.gamepad;

    case 'keyboardO':
      return FontAwesomeIcons.solidKeyboard;

    case 'flagO':
      return FontAwesomeIcons.solidFlag;

    case 'flagCheckered':
      return FontAwesomeIcons.flagCheckered;

    case 'terminal':
      return FontAwesomeIcons.terminal;

    case 'code':
      return FontAwesomeIcons.code;

    case 'mailReplyAll':
      return FontAwesomeIcons.replyAll;

    case 'replyAll':
      return FontAwesomeIcons.replyAll;

    case 'starHalfEmpty':
      return FontAwesomeIcons.starHalfAlt;

    case 'starHalfFull':
      return FontAwesomeIcons.starHalfAlt;

    case 'starHalfO':
      return FontAwesomeIcons.solidStarHalf;

    case 'locationArrow':
      return FontAwesomeIcons.locationArrow;

    case 'crop':
      return FontAwesomeIcons.crop;

    case 'codeFork':
      return FontAwesomeIcons.codeBranch;

    case 'unlink':
      return FontAwesomeIcons.unlink;

    case 'chainBroken':
      return FontAwesomeIcons.unlink;

    case 'question':
      return FontAwesomeIcons.question;

    case 'info':
      return FontAwesomeIcons.info;

    case 'exclamation':
      return FontAwesomeIcons.exclamation;

    case 'superscript':
      return FontAwesomeIcons.superscript;

    case 'subscript':
      return FontAwesomeIcons.subscript;

    case 'eraser':
      return FontAwesomeIcons.eraser;

    case 'puzzlePiece':
      return FontAwesomeIcons.puzzlePiece;

    case 'microphone':
      return FontAwesomeIcons.microphone;

    case 'microphoneSlash':
      return FontAwesomeIcons.microphoneSlash;

    case 'shield':
      return FontAwesomeIcons.shieldAlt;

    case 'calendarO':
      return FontAwesomeIcons.solidCalendar;

    case 'fireExtinguisher':
      return FontAwesomeIcons.fireExtinguisher;

    case 'rocket':
      return FontAwesomeIcons.rocket;

    case 'maxcdn':
      return FontAwesomeIcons.maxcdn;

    case 'chevronCircleLeft':
      return FontAwesomeIcons.chevronCircleLeft;

    case 'chevronCircleRight':
      return FontAwesomeIcons.chevronCircleRight;

    case 'chevronCircleUp':
      return FontAwesomeIcons.chevronCircleUp;

    case 'chevronCircleDown':
      return FontAwesomeIcons.chevronCircleDown;

    case 'html5':
      return FontAwesomeIcons.html5;

    case 'css3':
      return FontAwesomeIcons.css3;

    case 'anchor':
      return FontAwesomeIcons.anchor;

    case 'unlockAlt':
      return FontAwesomeIcons.unlockAlt;

    case 'bullseye':
      return FontAwesomeIcons.bullseye;

    case 'ellipsisH':
      return FontAwesomeIcons.ellipsisH;

    case 'ellipsisV':
      return FontAwesomeIcons.ellipsisV;

    case 'rssSquare':
      return FontAwesomeIcons.rssSquare;

    case 'playCircle':
      return FontAwesomeIcons.playCircle;

    case 'ticket':
      return FontAwesomeIcons.ticketAlt;

    case 'minusSquare':
      return FontAwesomeIcons.minusSquare;

    case 'minusSquareO':
      return FontAwesomeIcons.solidMinusSquare;

    case 'levelUp':
      return FontAwesomeIcons.levelUpAlt;

    case 'levelDown':
      return FontAwesomeIcons.levelDownAlt;

    case 'checkSquare':
      return FontAwesomeIcons.checkSquare;

    case 'pencilSquare':
      return FontAwesomeIcons.penSquare;

    case 'externalLinkSquare':
      return FontAwesomeIcons.externalLinkSquareAlt;

    case 'shareSquare':
      return FontAwesomeIcons.shareSquare;

    case 'compass':
      return FontAwesomeIcons.compass;

    case 'alignLeft':
      return FontAwesomeIcons.alignLeft;

    case 'turkishLira':
      return FontAwesomeIcons.liraSign;

    case 'meanpath':
      return FontAwesomeIcons.fontAwesome;

    case 'try':
      return FontAwesomeIcons.liraSign;

    case 'caretSquareODown':
      return FontAwesomeIcons.solidCaretSquareDown;

    case 'toggleUp':
      return FontAwesomeIcons.toggleOn;

    case 'caretSquareOUp':
      return FontAwesomeIcons.solidCaretSquareUp;

    case 'toggleRight':
      return FontAwesomeIcons.question;

    case 'caretSquareORight':
      return FontAwesomeIcons.solidCaretSquareRight;

    case 'euro':
      return FontAwesomeIcons.euroSign;

    case 'eur':
      return FontAwesomeIcons.euroSign;

    case 'gbp':
      return FontAwesomeIcons.poundSign;

    case 'dollar':
      return FontAwesomeIcons.dollarSign;

    case 'usd':
      return FontAwesomeIcons.dollarSign;

    case 'rupee':
      return FontAwesomeIcons.rupeeSign;

    case 'inr':
      return FontAwesomeIcons.rupeeSign;

    case 'cny':
      return FontAwesomeIcons.yenSign;

    case 'rmb':
      return FontAwesomeIcons.yenSign;

    case 'yen':
      return FontAwesomeIcons.yenSign;

    case 'jpy':
      return FontAwesomeIcons.yenSign;

    case 'ruble':
      return FontAwesomeIcons.rubleSign;

    case 'rouble':
      return FontAwesomeIcons.rubleSign;

    case 'rub':
      return FontAwesomeIcons.rubleSign;

    case 'won':
      return FontAwesomeIcons.wonSign;

    case 'krw':
      return FontAwesomeIcons.wonSign;

    case 'bitcoin':
      return FontAwesomeIcons.bitcoin;

    case 'btc':
      return FontAwesomeIcons.btc;

    case 'file':
      return FontAwesomeIcons.file;

    case 'fileText':
      return FontAwesomeIcons.fileAlt;

    case 'sortAlphaAsc':
      return FontAwesomeIcons.sortAlphaDown;

    case 'sortAlphaDesc':
      return FontAwesomeIcons.sortAlphaUp;

    case 'sortAmountAsc':
      return FontAwesomeIcons.sortAmountDown;

    case 'sortAmountDesc':
      return FontAwesomeIcons.sortAmountUp;

    case 'sortNumericAsc':
      return FontAwesomeIcons.sortNumericDown;

    case 'sortNumericDesc':
      return FontAwesomeIcons.sortNumericUp;

    case 'thumbsUp':
      return FontAwesomeIcons.thumbsUp;

    case 'thumbsDown':
      return FontAwesomeIcons.thumbsDown;

    case 'youtubeSquare':
      return FontAwesomeIcons.youtubeSquare;

    case 'youtube':
      return FontAwesomeIcons.youtube;

    case 'xing':
      return FontAwesomeIcons.xing;

    case 'xingSquare':
      return FontAwesomeIcons.xingSquare;

    case 'youtubePlay':
      return FontAwesomeIcons.youtube;

    case 'dropbox':
      return FontAwesomeIcons.dropbox;

    case 'stackOverflow':
      return FontAwesomeIcons.stackOverflow;

    case 'instagram':
      return FontAwesomeIcons.instagram;

    case 'flickr':
      return FontAwesomeIcons.flickr;

    case 'adn':
      return FontAwesomeIcons.adn;

    case 'bitbucket':
      return FontAwesomeIcons.bitbucket;

    case 'bitbucketSquare':
      return FontAwesomeIcons.bitbucket;

    case 'tumblr':
      return FontAwesomeIcons.tumblr;

    case 'tumblrSquare':
      return FontAwesomeIcons.tumblrSquare;

    case 'longArrowDown':
      return FontAwesomeIcons.longArrowAltDown;

    case 'longArrowUp':
      return FontAwesomeIcons.longArrowAltUp;

    case 'longArrowLeft':
      return FontAwesomeIcons.longArrowAltLeft;

    case 'longArrowRight':
      return FontAwesomeIcons.longArrowAltRight;

    case 'apple':
      return FontAwesomeIcons.apple;

    case 'windows':
      return FontAwesomeIcons.windows;

    case 'android':
      return FontAwesomeIcons.android;

    case 'linux':
      return FontAwesomeIcons.linux;

    case 'dribbble':
      return FontAwesomeIcons.dribbble;

    case 'skype':
      return FontAwesomeIcons.skype;

    case 'foursquare':
      return FontAwesomeIcons.foursquare;

    case 'trello':
      return FontAwesomeIcons.trello;

    case 'female':
      return FontAwesomeIcons.female;

    case 'male':
      return FontAwesomeIcons.male;

    case 'gittip':
      return FontAwesomeIcons.gratipay;

    case 'gratipay':
      return FontAwesomeIcons.gratipay;

    case 'sunO':
      return FontAwesomeIcons.solidSun;

    case 'moonO':
      return FontAwesomeIcons.solidMoon;

    case 'archive':
      return FontAwesomeIcons.archive;

    case 'bug':
      return FontAwesomeIcons.bug;

    case 'vk':
      return FontAwesomeIcons.vk;

    case 'weibo':
      return FontAwesomeIcons.weibo;

    case 'renren':
      return FontAwesomeIcons.renren;

    case 'pagelines':
      return FontAwesomeIcons.pagelines;

    case 'stackExchange':
      return FontAwesomeIcons.stackExchange;

    case 'arrowCircleORight':
      return FontAwesomeIcons.solidArrowAltCircleRight;

    case 'arrowCircleOLeft':
      return FontAwesomeIcons.solidArrowAltCircleLeft;

    case 'caretSquareOLeft':
      return FontAwesomeIcons.solidCaretSquareLeft;

    case 'dotCircleO':
      return FontAwesomeIcons.solidDotCircle;

    case 'wheelchair':
      return FontAwesomeIcons.wheelchair;

    case 'vimeoSquare':
      return FontAwesomeIcons.vimeoSquare;

    case 'plusSquareO':
      return FontAwesomeIcons.solidPlusSquare;

    case 'spaceShuttle':
      return FontAwesomeIcons.spaceShuttle;

    case 'slack':
      return FontAwesomeIcons.slack;

    case 'envelopeSquare':
      return FontAwesomeIcons.envelopeSquare;

    case 'wordpress':
      return FontAwesomeIcons.wordpress;

    case 'openid':
      return FontAwesomeIcons.openid;

    case 'institution':
      return FontAwesomeIcons.university;

    case 'bank':
      return FontAwesomeIcons.university;

    case 'university':
      return FontAwesomeIcons.university;

    case 'mortarBoard':
      return FontAwesomeIcons.graduationCap;

    case 'graduationCap':
      return FontAwesomeIcons.graduationCap;

    case 'yahoo':
      return FontAwesomeIcons.yahoo;

    case 'google':
      return FontAwesomeIcons.google;

    case 'reddit':
      return FontAwesomeIcons.reddit;

    case 'redditSquare':
      return FontAwesomeIcons.redditSquare;

    case 'stumbleuponCircle':
      return FontAwesomeIcons.stumbleuponCircle;

    case 'stumbleupon':
      return FontAwesomeIcons.stumbleupon;

    case 'delicious':
      return FontAwesomeIcons.delicious;

    case 'digg':
      return FontAwesomeIcons.digg;

    case 'piedPiper':
      return FontAwesomeIcons.piedPiper;

    case 'piedPiperAlt':
      return FontAwesomeIcons.piedPiperAlt;

    case 'drupal':
      return FontAwesomeIcons.drupal;

    case 'joomla':
      return FontAwesomeIcons.joomla;

    case 'language':
      return FontAwesomeIcons.language;

    case 'fax':
      return FontAwesomeIcons.fax;

    case 'building':
      return FontAwesomeIcons.building;

    case 'child':
      return FontAwesomeIcons.child;

    case 'paw':
      return FontAwesomeIcons.paw;

    case 'spoon':
      return FontAwesomeIcons.utensilSpoon;

    case 'cube':
      return FontAwesomeIcons.cube;

    case 'cubes':
      return FontAwesomeIcons.cubes;

    case 'behance':
      return FontAwesomeIcons.behance;

    case 'behanceSquare':
      return FontAwesomeIcons.behanceSquare;

    case 'steam':
      return FontAwesomeIcons.steam;

    case 'steamSquare':
      return FontAwesomeIcons.steamSquare;

    case 'recycle':
      return FontAwesomeIcons.recycle;

    case 'automobile':
      return FontAwesomeIcons.car;

    case 'car':
      return FontAwesomeIcons.car;

    case 'cab':
      return FontAwesomeIcons.taxi;

    case 'taxi':
      return FontAwesomeIcons.taxi;

    case 'tree':
      return FontAwesomeIcons.tree;

    case 'spotify':
      return FontAwesomeIcons.spotify;

    case 'deviantart':
      return FontAwesomeIcons.deviantart;

    case 'soundcloud':
      return FontAwesomeIcons.soundcloud;

    case 'database':
      return FontAwesomeIcons.database;

    case 'filePdfO':
      return FontAwesomeIcons.solidFilePdf;

    case 'fileWordO':
      return FontAwesomeIcons.solidFileWord;

    case 'fileExcelO':
      return FontAwesomeIcons.solidFileExcel;

    case 'filePowerpointO':
      return FontAwesomeIcons.solidFilePowerpoint;

    case 'filePhotoO':
      return FontAwesomeIcons.solidFileImage;

    case 'filePictureO':
      return FontAwesomeIcons.solidFileImage;

    case 'fileImageO':
      return FontAwesomeIcons.solidFileImage;

    case 'fileZipO':
      return FontAwesomeIcons.fileArchive;

    case 'fileArchiveO':
      return FontAwesomeIcons.solidFileArchive;

    case 'fileSoundO':
      return FontAwesomeIcons.solidFileAudio;

    case 'fileAudioO':
      return FontAwesomeIcons.solidFileAudio;

    case 'fileMovieO':
      return FontAwesomeIcons.solidFileVideo;

    case 'fileVideoO':
      return FontAwesomeIcons.solidFileVideo;

    case 'fileCodeO':
      return FontAwesomeIcons.solidFileCode;

    case 'vine':
      return FontAwesomeIcons.vine;

    case 'codepen':
      return FontAwesomeIcons.codepen;

    case 'jsfiddle':
      return FontAwesomeIcons.jsfiddle;

    case 'lifeBouy':
      return FontAwesomeIcons.lifeRing;

    case 'lifeBuoy':
      return FontAwesomeIcons.lifeRing;

    case 'lifeSaver':
      return FontAwesomeIcons.lifeRing;

    case 'support':
      return FontAwesomeIcons.phoneSquare;

    case 'lifeRing':
      return FontAwesomeIcons.lifeRing;

    case 'circleONotch':
      return FontAwesomeIcons.circleNotch;

    case 'ra':
      return FontAwesomeIcons.rebel;

    case 'rebel':
      return FontAwesomeIcons.rebel;

    case 'ge':
      return FontAwesomeIcons.empire;

    case 'empire':
      return FontAwesomeIcons.empire;

    case 'gitSquare':
      return FontAwesomeIcons.gitSquare;

    case 'git':
      return FontAwesomeIcons.git;

    case 'yCombinatorSquare':
      return FontAwesomeIcons.yCombinator;

    case 'ycSquare':
      return FontAwesomeIcons.hackerNewsSquare;

    case 'hackerNews':
      return FontAwesomeIcons.hackerNews;

    case 'tencentWeibo':
      return FontAwesomeIcons.tencentWeibo;

    case 'qq':
      return FontAwesomeIcons.qq;

    case 'wechat':
      return FontAwesomeIcons.weixin;

    case 'weixin':
      return FontAwesomeIcons.weixin;

    case 'send':
      return FontAwesomeIcons.solidShareSquare;

    case 'paperPlane':
      return FontAwesomeIcons.paperPlane;

    case 'sendO':
      return FontAwesomeIcons.shareSquare;

    case 'paperPlaneO':
      return FontAwesomeIcons.solidPaperPlane;

    case 'history':
      return FontAwesomeIcons.history;

    case 'circleThin':
      return FontAwesomeIcons.circle;

    case 'header':
      return FontAwesomeIcons.heading;

    case 'paragraph':
      return FontAwesomeIcons.paragraph;

    case 'sliders':
      return FontAwesomeIcons.slidersH;

    case 'shareAlt':
      return FontAwesomeIcons.shareAlt;

    case 'shareAltSquare':
      return FontAwesomeIcons.shareAltSquare;

    case 'bomb':
      return FontAwesomeIcons.bomb;

    case 'soccerBallO':
      return FontAwesomeIcons.solidFutbol;

    case 'futbolO':
      return FontAwesomeIcons.solidFutbol;

    case 'tty':
      return FontAwesomeIcons.tty;

    case 'binoculars':
      return FontAwesomeIcons.binoculars;

    case 'plug':
      return FontAwesomeIcons.plug;

    case 'slideshare':
      return FontAwesomeIcons.slideshare;

    case 'twitch':
      return FontAwesomeIcons.twitch;

    case 'yelp':
      return FontAwesomeIcons.yelp;

    case 'newspaperO':
      return FontAwesomeIcons.solidNewspaper;

    case 'wifi':
      return FontAwesomeIcons.wifi;

    case 'calculator':
      return FontAwesomeIcons.calculator;

    case 'paypal':
      return FontAwesomeIcons.paypal;

    case 'googleWallet':
      return FontAwesomeIcons.googleWallet;

    case 'ccVisa':
      return FontAwesomeIcons.ccVisa;

    case 'ccMastercard':
      return FontAwesomeIcons.ccMastercard;

    case 'ccDiscover':
      return FontAwesomeIcons.ccDiscover;

    case 'ccAmex':
      return FontAwesomeIcons.ccAmex;

    case 'ccPaypal':
      return FontAwesomeIcons.ccPaypal;

    case 'ccStripe':
      return FontAwesomeIcons.ccStripe;

    case 'bellSlash':
      return FontAwesomeIcons.bellSlash;

    case 'bellSlashO':
      return FontAwesomeIcons.solidBellSlash;

    case 'trash':
      return FontAwesomeIcons.trash;

    case 'copyright':
      return FontAwesomeIcons.copyright;

    case 'at':
      return FontAwesomeIcons.at;

    case 'eyedropper':
      return FontAwesomeIcons.eyeDropper;

    case 'paintBrush':
      return FontAwesomeIcons.paintBrush;

    case 'birthdayCake':
      return FontAwesomeIcons.birthdayCake;

    case 'areaChart':
      return FontAwesomeIcons.chartArea;

    case 'pieChart':
      return FontAwesomeIcons.chartPie;

    case 'lineChart':
      return FontAwesomeIcons.chartLine;

    case 'lastfm':
      return FontAwesomeIcons.lastfm;

    case 'lastfmSquare':
      return FontAwesomeIcons.lastfmSquare;

    case 'toggleOff':
      return FontAwesomeIcons.toggleOff;

    case 'toggleOn':
      return FontAwesomeIcons.toggleOn;

    case 'bicycle':
      return FontAwesomeIcons.bicycle;

    case 'bus':
      return FontAwesomeIcons.bus;

    case 'ioxhost':
      return FontAwesomeIcons.ioxhost;

    case 'angellist':
      return FontAwesomeIcons.angellist;

    case 'cc':
      return FontAwesomeIcons.closedCaptioning;

    case 'shekel':
      return FontAwesomeIcons.shekelSign;

    case 'sheqel':
      return FontAwesomeIcons.shekelSign;

    case 'ils':
      return FontAwesomeIcons.shekelSign;

    case 'buysellads':
      return FontAwesomeIcons.buysellads;

    case 'connectdevelop':
      return FontAwesomeIcons.connectdevelop;

    case 'dashcube':
      return FontAwesomeIcons.dashcube;

    case 'forumbee':
      return FontAwesomeIcons.forumbee;

    case 'leanpub':
      return FontAwesomeIcons.leanpub;

    case 'sellsy':
      return FontAwesomeIcons.sellsy;

    case 'shirtsinbulk':
      return FontAwesomeIcons.shirtsinbulk;

    case 'simplybuilt':
      return FontAwesomeIcons.simplybuilt;

    case 'skyatlas':
      return FontAwesomeIcons.skyatlas;

    case 'cartPlus':
      return FontAwesomeIcons.cartPlus;

    case 'cartArrowDown':
      return FontAwesomeIcons.cartArrowDown;

    case 'diamond':
      return FontAwesomeIcons.gem;

    case 'ship':
      return FontAwesomeIcons.ship;

    case 'userSecret':
      return FontAwesomeIcons.userSecret;

    case 'motorcycle':
      return FontAwesomeIcons.motorcycle;

    case 'streetView':
      return FontAwesomeIcons.streetView;

    case 'heartbeat':
      return FontAwesomeIcons.heartbeat;

    case 'venus':
      return FontAwesomeIcons.venus;

    case 'mars':
      return FontAwesomeIcons.mars;

    case 'mercury':
      return FontAwesomeIcons.mercury;

    case 'intersex':
      return FontAwesomeIcons.transgender;

    case 'transgender':
      return FontAwesomeIcons.transgender;

    case 'transgenderAlt':
      return FontAwesomeIcons.transgenderAlt;

    case 'venusDouble':
      return FontAwesomeIcons.venusDouble;

    case 'marsDouble':
      return FontAwesomeIcons.marsDouble;

    case 'venusMars':
      return FontAwesomeIcons.venusMars;

    case 'marsStroke':
      return FontAwesomeIcons.marsStroke;

    case 'marsStrokeV':
      return FontAwesomeIcons.marsStrokeV;

    case 'marsStrokeH':
      return FontAwesomeIcons.marsStrokeH;

    case 'neuter':
      return FontAwesomeIcons.neuter;

    case 'genderless':
      return FontAwesomeIcons.genderless;

    case 'facebookOfficial':
      return FontAwesomeIcons.facebook;

    case 'pinterestP':
      return FontAwesomeIcons.pinterestP;

    case 'whatsapp':
      return FontAwesomeIcons.whatsapp;

    case 'server':
      return FontAwesomeIcons.server;

    case 'userPlus':
      return FontAwesomeIcons.userPlus;

    case 'userTimes':
      return FontAwesomeIcons.userTimes;

    case 'hotel':
      return FontAwesomeIcons.hotel;

    case 'bed':
      return FontAwesomeIcons.bed;

    case 'viacoin':
      return FontAwesomeIcons.viacoin;

    case 'train':
      return FontAwesomeIcons.train;

    case 'subway':
      return FontAwesomeIcons.subway;

    case 'medium':
      return FontAwesomeIcons.medium;

    case 'yc':
      return FontAwesomeIcons.yCombinator;

    case 'yCombinator':
      return FontAwesomeIcons.yCombinator;

    case 'optinMonster':
      return FontAwesomeIcons.optinMonster;

    case 'opencart':
      return FontAwesomeIcons.opencart;

    case 'expeditedssl':
      return FontAwesomeIcons.expeditedssl;

    case 'battery4':
      return FontAwesomeIcons.batteryFull;

    case 'batteryFull':
      return FontAwesomeIcons.batteryFull;

    case 'battery3':
      return FontAwesomeIcons.batteryThreeQuarters;

    case 'batteryThreeQuarters':
      return FontAwesomeIcons.batteryThreeQuarters;

    case 'battery2':
      return FontAwesomeIcons.batteryHalf;

    case 'batteryHalf':
      return FontAwesomeIcons.batteryHalf;

    case 'battery1':
      return FontAwesomeIcons.batteryQuarter;

    case 'batteryQuarter':
      return FontAwesomeIcons.batteryQuarter;

    case 'battery0':
      return FontAwesomeIcons.batteryEmpty;

    case 'batteryEmpty':
      return FontAwesomeIcons.batteryEmpty;

    case 'mousePointer':
      return FontAwesomeIcons.mousePointer;

    case 'iCursor':
      return FontAwesomeIcons.iCursor;

    case 'objectGroup':
      return FontAwesomeIcons.objectGroup;

    case 'objectUngroup':
      return FontAwesomeIcons.objectUngroup;

    case 'stickyNote':
      return FontAwesomeIcons.stickyNote;

    case 'stickyNoteO':
      return FontAwesomeIcons.stickyNote;

    case 'ccJcb':
      return FontAwesomeIcons.ccJcb;

    case 'ccDinersClub':
      return FontAwesomeIcons.ccDinersClub;

    case 'clone':
      return FontAwesomeIcons.clone;

    case 'balanceScale':
      return FontAwesomeIcons.balanceScale;

    case 'hourglassO':
      return FontAwesomeIcons.hourglass;

    case 'hourglass1':
      return FontAwesomeIcons.hourglassStart;

    case 'hourglassStart':
      return FontAwesomeIcons.hourglassStart;

    case 'hourglass2':
      return FontAwesomeIcons.hourglassHalf;

    case 'hourglassHalf':
      return FontAwesomeIcons.hourglassHalf;

    case 'hourglass3':
      return FontAwesomeIcons.hourglassEnd;

    case 'hourglassEnd':
      return FontAwesomeIcons.hourglassEnd;

    case 'hourglass':
      return FontAwesomeIcons.hourglass;

    case 'handGrabO':
      return FontAwesomeIcons.solidHandRock;

    case 'handRockO':
      return FontAwesomeIcons.solidHandRock;

    case 'handStopO':
      return FontAwesomeIcons.solidHandPaper;

    case 'handPaperO':
      return FontAwesomeIcons.solidHandPaper;

    case 'handScissorsO':
      return FontAwesomeIcons.solidHandScissors;

    case 'handLizardO':
      return FontAwesomeIcons.solidHandLizard;

    case 'handSpockO':
      return FontAwesomeIcons.solidHandSpock;

    case 'handPointerO':
      return FontAwesomeIcons.solidHandPointer;

    case 'handPeaceO':
      return FontAwesomeIcons.solidHandPeace;

    case 'trademark':
      return FontAwesomeIcons.trademark;

    case 'registered':
      return FontAwesomeIcons.registered;

    case 'creativeCommons':
      return FontAwesomeIcons.creativeCommons;

    case 'gg':
      return FontAwesomeIcons.gg;

    case 'ggCircle':
      return FontAwesomeIcons.ggCircle;

    case 'tripadvisor':
      return FontAwesomeIcons.tripadvisor;

    case 'odnoklassniki':
      return FontAwesomeIcons.odnoklassniki;

    case 'odnoklassnikiSquare':
      return FontAwesomeIcons.odnoklassnikiSquare;

    case 'getPocket':
      return FontAwesomeIcons.getPocket;

    case 'wikipediaW':
      return FontAwesomeIcons.wikipediaW;

    case 'safari':
      return FontAwesomeIcons.safari;

    case 'chrome':
      return FontAwesomeIcons.chrome;

    case 'firefox':
      return FontAwesomeIcons.firefox;

    case 'opera':
      return FontAwesomeIcons.opera;

    case 'internetExplorer':
      return FontAwesomeIcons.internetExplorer;

    case 'tv':
      return FontAwesomeIcons.tv;

    case 'television':
      return FontAwesomeIcons.tv;

    case 'contao':
      return FontAwesomeIcons.contao;

    case 'px':
      return FontAwesomeIcons.fiveHundredPx;

    case 'amazon':
      return FontAwesomeIcons.amazon;

    case 'calendarPlusO':
      return FontAwesomeIcons.solidCalendarPlus;

    case 'calendarMinusO':
      return FontAwesomeIcons.solidCalendarMinus;

    case 'calendarTimesO':
      return FontAwesomeIcons.solidCalendarTimes;

    case 'calendarCheckO':
      return FontAwesomeIcons.solidCalendarCheck;

    case 'industry':
      return FontAwesomeIcons.industry;

    case 'mapPin':
      return FontAwesomeIcons.mapPin;

    case 'mapSigns':
      return FontAwesomeIcons.mapSigns;

    case 'mapO':
      return FontAwesomeIcons.solidMap;

    case 'map':
      return FontAwesomeIcons.map;

    case 'commenting':
      return FontAwesomeIcons.commentDots;
    case 'commentingO':
      return FontAwesomeIcons.solidCommentDots;
    case 'houzz':
      return FontAwesomeIcons.houzz;
    case 'vimeo':
      return FontAwesomeIcons.vimeo;
    case 'blackTie':
      return FontAwesomeIcons.blackTie;
    case 'fonticons':
      return FontAwesomeIcons.fonticons;
    default:
      return FontAwesomeIcons.questionCircle;
  }
}
