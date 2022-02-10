import 'package:flutter/material.dart';
import 'parse_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// This
abstract class IFontAwesome {
  static bool checkFontAwesome(String pText) {
    return pText.contains('FontAwesome');
  }

  static FaIcon getFontAwesomeIcon(String pText) {
    List<String> arr = pText.split(",");

    if (arr[0].contains(";")) {
      var nameAndSize = arr[0].split(";");

      arr[0] = nameAndSize[0];
      arr.add(nameAndSize[1]);
    }

    String iconName = arr[0];
    Size iconSize = Size(double.parse(arr[1]), double.parse(arr[2]));
    Color iconColor = arr.length > 4 ? (ParseUtil.parseHexColor(arr[4]) ?? Colors.black) : Colors.black;

    IconData iconData = ICONS[iconName] ?? FontAwesomeIcons.questionCircle;

    return FaIcon(
      iconData,
      size: iconSize.width,
      color: iconColor,
    );
  }

  static const Map<String, IconData> ICONS = {
    "FontAwesome.glass": FontAwesomeIcons.glassWhiskey,
    "FontAwesome.music": FontAwesomeIcons.music,
    "FontAwesome.search": FontAwesomeIcons.search,
    "FontAwesome.envelope-o": FontAwesomeIcons.solidEnvelope,
    "FontAwesome.heart": FontAwesomeIcons.heart,
    "FontAwesome.star": FontAwesomeIcons.star,
    "FontAwesome.star-o": FontAwesomeIcons.solidStar,
    "FontAwesome.user": FontAwesomeIcons.user,
    "FontAwesome.film": FontAwesomeIcons.film,
    "FontAwesome.th-large": FontAwesomeIcons.thLarge,
    "FontAwesome.th": FontAwesomeIcons.th,
    "FontAwesome.th-list": FontAwesomeIcons.thList,
    "FontAwesome.check": FontAwesomeIcons.check,
    "FontAwesome.remove": FontAwesomeIcons.trashAlt,
    "FontAwesome.close": FontAwesomeIcons.times,
    "FontAwesome.times": FontAwesomeIcons.times,
    "FontAwesome.search-plus": FontAwesomeIcons.searchPlus,
    "FontAwesome.search-minus": FontAwesomeIcons.searchMinus,
    "FontAwesome.power-off": FontAwesomeIcons.powerOff,
    "FontAwesome.signal": FontAwesomeIcons.signal,
    "FontAwesome.gear": FontAwesomeIcons.cogs,
    "FontAwesome.cog": FontAwesomeIcons.cog,
    "FontAwesome.trash-o": FontAwesomeIcons.solidTrashAlt,
    "FontAwesome.home": FontAwesomeIcons.home,
    "FontAwesome.file-o": FontAwesomeIcons.solidFile,
    "FontAwesome.clock-o": FontAwesomeIcons.solidClock,
    "FontAwesome.road": FontAwesomeIcons.road,
    "FontAwesome.download": FontAwesomeIcons.download,
    "FontAwesome.arrow-circle-o-down": FontAwesomeIcons.solidArrowAltCircleDown,
    "FontAwesome.arrow-circle-o-up": FontAwesomeIcons.solidArrowAltCircleUp,
    "FontAwesome.inbox": FontAwesomeIcons.inbox,
    "FontAwesome.play-circle-o": FontAwesomeIcons.solidPlayCircle,
    "FontAwesome.rotate-right": FontAwesomeIcons.sync,
    "FontAwesome.repeat": FontAwesomeIcons.redoAlt,
    "FontAwesome.refresh": FontAwesomeIcons.redo,
    "FontAwesome.list-alt": FontAwesomeIcons.listAlt,
    "FontAwesome.lock": FontAwesomeIcons.lock,
    "FontAwesome.flag": FontAwesomeIcons.flag,
    "FontAwesome.headphones": FontAwesomeIcons.headphones,
    "FontAwesome.volume-off": FontAwesomeIcons.volumeOff,
    "FontAwesome.volume-down": FontAwesomeIcons.volumeDown,
    "FontAwesome.volume-up": FontAwesomeIcons.volumeUp,
    "FontAwesome.qrcode": FontAwesomeIcons.qrcode,
    "FontAwesome.barcode": FontAwesomeIcons.barcode,
    "FontAwesome.tag": FontAwesomeIcons.tag,
    "FontAwesome.tags": FontAwesomeIcons.tags,
    "FontAwesome.book": FontAwesomeIcons.book,
    "FontAwesome.bookmark": FontAwesomeIcons.bookmark,
    "FontAwesome.print": FontAwesomeIcons.print,
    "FontAwesome.camera": FontAwesomeIcons.camera,
    "FontAwesome.font": FontAwesomeIcons.font,
    "FontAwesome.bold": FontAwesomeIcons.bold,
    "FontAwesome.italic": FontAwesomeIcons.italic,
    "FontAwesome.text-height": FontAwesomeIcons.textHeight,
    "FontAwesome.text-width": FontAwesomeIcons.textWidth,
    "FontAwesome.align-left": FontAwesomeIcons.alignLeft,
    "FontAwesome.align-center": FontAwesomeIcons.alignCenter,
    "FontAwesome.align-right": FontAwesomeIcons.alignRight,
    "FontAwesome.align-justify": FontAwesomeIcons.alignJustify,
    "FontAwesome.list": FontAwesomeIcons.list,
    "FontAwesome.dedent": FontAwesomeIcons.outdent,
    "FontAwesome.outdent": FontAwesomeIcons.outdent,
    "FontAwesome.indent": FontAwesomeIcons.indent,
    "FontAwesome.video-camera": FontAwesomeIcons.video,
    "FontAwesome.photo": FontAwesomeIcons.image,
    "FontAwesome.image": FontAwesomeIcons.image,
    "FontAwesome.picture-o": FontAwesomeIcons.solidImage,
    "FontAwesome.pencil": FontAwesomeIcons.pencilAlt,
    "FontAwesome.map-marker": FontAwesomeIcons.mapMarker,
    "FontAwesome.adjust": FontAwesomeIcons.adjust,
    "FontAwesome.tint": FontAwesomeIcons.tint,
    "FontAwesome.edit": FontAwesomeIcons.edit,
    "FontAwesome.pencil-square-o": FontAwesomeIcons.penSquare,
    "FontAwesome.share-square-o": FontAwesomeIcons.solidShareSquare,
    "FontAwesome.check-square-o": FontAwesomeIcons.solidCheckSquare,
    "FontAwesome.arrows": FontAwesomeIcons.arrowsAlt,
    "FontAwesome.step-backward": FontAwesomeIcons.stepBackward,
    "FontAwesome.fast-backward": FontAwesomeIcons.fastBackward,
    "FontAwesome.backward": FontAwesomeIcons.backward,
    "FontAwesome.play": FontAwesomeIcons.play,
    "FontAwesome.pause": FontAwesomeIcons.pause,
    "FontAwesome.stop": FontAwesomeIcons.stop,
    "FontAwesome.forward": FontAwesomeIcons.forward,
    "FontAwesome.fast-forward": FontAwesomeIcons.fastForward,
    "FontAwesome.step-forward": FontAwesomeIcons.stepForward,
    "FontAwesome.eject": FontAwesomeIcons.eject,
    "FontAwesome.chevron-left": FontAwesomeIcons.chevronLeft,
    "FontAwesome.chevron-right": FontAwesomeIcons.chevronRight,
    "FontAwesome.plus-circle": FontAwesomeIcons.plusCircle,
    "FontAwesome.minus-circle": FontAwesomeIcons.minusCircle,
    "FontAwesome.times-circle": FontAwesomeIcons.timesCircle,
    "FontAwesome.check-circle": FontAwesomeIcons.checkCircle,
    "FontAwesome.question-circle": FontAwesomeIcons.questionCircle,
    "FontAwesome.info-circle": FontAwesomeIcons.infoCircle,
    "FontAwesome.crosshairs": FontAwesomeIcons.crosshairs,
    "FontAwesome.times-circle-o": FontAwesomeIcons.solidTimesCircle,
    "FontAwesome.check-circle-o": FontAwesomeIcons.solidCheckCircle,
    "FontAwesome.ban": FontAwesomeIcons.ban,
    "FontAwesome.arrow-left": FontAwesomeIcons.arrowLeft,
    "FontAwesome.arrow-right": FontAwesomeIcons.arrowRight,
    "FontAwesome.arrow-up": FontAwesomeIcons.arrowUp,
    "FontAwesome.arrow-down": FontAwesomeIcons.arrowDown,
    "FontAwesome.mail-forward": FontAwesomeIcons.share,
    "FontAwesome.share": FontAwesomeIcons.share,
    "FontAwesome.expand": FontAwesomeIcons.expand,
    "FontAwesome.compress": FontAwesomeIcons.compress,
    "FontAwesome.plus": FontAwesomeIcons.plus,
    "FontAwesome.minus": FontAwesomeIcons.minus,
    "FontAwesome.asterisk": FontAwesomeIcons.asterisk,
    "FontAwesome.exclamation-circle": FontAwesomeIcons.exclamationCircle,
    "FontAwesome.gift": FontAwesomeIcons.gift,
    "FontAwesome.leaf": FontAwesomeIcons.leaf,
    "FontAwesome.fire": FontAwesomeIcons.fire,
    "FontAwesome.eye": FontAwesomeIcons.eye,
    "FontAwesome.eye-slash": FontAwesomeIcons.eyeSlash,
    "FontAwesome.warning": FontAwesomeIcons.exclamation,
    "FontAwesome.exclamation-triangle": FontAwesomeIcons.exclamationTriangle,
    "FontAwesome.plane": FontAwesomeIcons.plane,
    "FontAwesome.calendar": FontAwesomeIcons.calendar,
    "FontAwesome.random": FontAwesomeIcons.random,
    "FontAwesome.comment": FontAwesomeIcons.comment,
    "FontAwesome.magnet": FontAwesomeIcons.magnet,
    "FontAwesome.chevron-up": FontAwesomeIcons.chevronUp,
    "FontAwesome.chevron-down": FontAwesomeIcons.chevronDown,
    "FontAwesome.retweet": FontAwesomeIcons.retweet,
    "FontAwesome.shopping-cart": FontAwesomeIcons.shoppingCart,
    "FontAwesome.folder": FontAwesomeIcons.folder,
    "FontAwesome.folder-open": FontAwesomeIcons.folderOpen,
    "FontAwesome.arrows-v": FontAwesomeIcons.arrowsAltV,
    "FontAwesome.arrows-h": FontAwesomeIcons.arrowsAltH,
    "FontAwesome.bar-chart-o": FontAwesomeIcons.solidChartBar,
    "FontAwesome.bar-chart": FontAwesomeIcons.chartBar,
    "FontAwesome.twitter-square": FontAwesomeIcons.twitterSquare,
    "FontAwesome.facebook-square": FontAwesomeIcons.facebookSquare,
    "FontAwesome.camera-retro": FontAwesomeIcons.cameraRetro,
    "FontAwesome.key": FontAwesomeIcons.key,
    "FontAwesome.gears": FontAwesomeIcons.cogs,
    "FontAwesome.cogs": FontAwesomeIcons.cogs,
    "FontAwesome.comments": FontAwesomeIcons.comments,
    "FontAwesome.thumbs-o-up": FontAwesomeIcons.solidThumbsUp,
    "FontAwesome.thumbs-o-down": FontAwesomeIcons.solidThumbsDown,
    "FontAwesome.star-half": FontAwesomeIcons.starHalf,
    "FontAwesome.heart-o": FontAwesomeIcons.solidHeart,
    "FontAwesome.sign-out": FontAwesomeIcons.signOutAlt,
    "FontAwesome.linkedin-square": FontAwesomeIcons.linkedin,
    "FontAwesome.thumb-tack": FontAwesomeIcons.thumbtack,
    "FontAwesome.external-link": FontAwesomeIcons.externalLinkAlt,
    "FontAwesome.sign-in": FontAwesomeIcons.signInAlt,
    "FontAwesome.trophy": FontAwesomeIcons.trophy,
    "FontAwesome.github-square": FontAwesomeIcons.githubSquare,
    "FontAwesome.upload": FontAwesomeIcons.upload,
    "FontAwesome.lemon-o": FontAwesomeIcons.solidLemon,
    "FontAwesome.phone": FontAwesomeIcons.phone,
    "FontAwesome.square-o": FontAwesomeIcons.solidSquare,
    "FontAwesome.bookmark-o": FontAwesomeIcons.solidBookmark,
    "FontAwesome.phone-square": FontAwesomeIcons.phoneSquare,
    "FontAwesome.twitter": FontAwesomeIcons.twitter,
    "FontAwesome.facebook-f": FontAwesomeIcons.facebookF,
    "FontAwesome.facebook": FontAwesomeIcons.facebook,
    "FontAwesome.github": FontAwesomeIcons.github,
    "FontAwesome.unlock": FontAwesomeIcons.unlock,
    "FontAwesome.credit-card": FontAwesomeIcons.creditCard,
    "FontAwesome.feed": FontAwesomeIcons.rss,
    "FontAwesome.rss": FontAwesomeIcons.rss,
    "FontAwesome.hdd-o": FontAwesomeIcons.solidHdd,
    "FontAwesome.bullhorn": FontAwesomeIcons.bullhorn,
    "FontAwesome.bell": FontAwesomeIcons.bell,
    "FontAwesome.certificate": FontAwesomeIcons.certificate,
    "FontAwesome.hand-o-right": FontAwesomeIcons.solidHandPointRight,
    "FontAwesome.hand-o-left": FontAwesomeIcons.solidHandPointLeft,
    "FontAwesome.hand-o-up": FontAwesomeIcons.solidHandPointUp,
    "FontAwesome.hand-o-down": FontAwesomeIcons.solidHandPointDown,
    "FontAwesome.arrow-circle-left": FontAwesomeIcons.arrowCircleLeft,
    "FontAwesome.arrow-circle-right": FontAwesomeIcons.arrowCircleRight,
    "FontAwesome.arrow-circle-up": FontAwesomeIcons.arrowCircleUp,
    "FontAwesome.arrow-circle-down": FontAwesomeIcons.arrowCircleDown,
    "FontAwesome.globe": FontAwesomeIcons.globe,
    "FontAwesome.wrench": FontAwesomeIcons.wrench,
    "FontAwesome.tasks": FontAwesomeIcons.tasks,
    "FontAwesome.filter": FontAwesomeIcons.filter,
    "FontAwesome.briefcase": FontAwesomeIcons.briefcase,
    "FontAwesome.arrows-alt": FontAwesomeIcons.arrowsAlt,
    "FontAwesome.group": FontAwesomeIcons.users,
    "FontAwesome.users": FontAwesomeIcons.users,
    "FontAwesome.chain": FontAwesomeIcons.link,
    "FontAwesome.link": FontAwesomeIcons.link,
    "FontAwesome.cloud": FontAwesomeIcons.cloud,
    "FontAwesome.flask": FontAwesomeIcons.flask,
    "FontAwesome.cut": FontAwesomeIcons.cut,
    "FontAwesome.scissors": FontAwesomeIcons.cut,
    "FontAwesome.copy": FontAwesomeIcons.copy,
    "FontAwesome.files-o": FontAwesomeIcons.solidFile,
    "FontAwesome.paperclip": FontAwesomeIcons.paperclip,
    "FontAwesome.save": FontAwesomeIcons.save,
    "FontAwesome.floppy-o": FontAwesomeIcons.save,
    "FontAwesome.square": FontAwesomeIcons.square,
    "FontAwesome.navicon": FontAwesomeIcons.bars,
    "FontAwesome.reorder": FontAwesomeIcons.bars,
    "FontAwesome.bars": FontAwesomeIcons.bars,
    "FontAwesome.list-ul": FontAwesomeIcons.listUl,
    "FontAwesome.list-ol": FontAwesomeIcons.listOl,
    "FontAwesome.strikethrough": FontAwesomeIcons.strikethrough,
    "FontAwesome.underline": FontAwesomeIcons.underline,
    "FontAwesome.table": FontAwesomeIcons.table,
    "FontAwesome.magic": FontAwesomeIcons.magic,
    "FontAwesome.truck": FontAwesomeIcons.truck,
    "FontAwesome.pinterest": FontAwesomeIcons.pinterest,
    "FontAwesome.pinterest-square": FontAwesomeIcons.pinterestSquare,
    "FontAwesome.google-plus-square": FontAwesomeIcons.googlePlusSquare,
    "FontAwesome.google-plus": FontAwesomeIcons.googlePlus,
    "FontAwesome.money": FontAwesomeIcons.moneyBill,
    "FontAwesome.caret-down": FontAwesomeIcons.caretDown,
    "FontAwesome.caret-up": FontAwesomeIcons.caretUp,
    "FontAwesome.caret-left": FontAwesomeIcons.caretLeft,
    "FontAwesome.caret-right": FontAwesomeIcons.caretRight,
    "FontAwesome.columns": FontAwesomeIcons.columns,
    "FontAwesome.unsorted": FontAwesomeIcons.sort,
    "FontAwesome.sort": FontAwesomeIcons.sort,
    "FontAwesome.sort-down": FontAwesomeIcons.sortDown,
    "FontAwesome.sort-desc": FontAwesomeIcons.sortNumericDown,
    "FontAwesome.sort-up": FontAwesomeIcons.sortUp,
    "FontAwesome.sort-asc": FontAwesomeIcons.sortNumericUp,
    "FontAwesome.envelope": FontAwesomeIcons.envelope,
    "FontAwesome.linkedin": FontAwesomeIcons.linkedin,
    "FontAwesome.rotate-left": FontAwesomeIcons.undo,
    "FontAwesome.undo": FontAwesomeIcons.undo,
    "FontAwesome.legal": FontAwesomeIcons.gavel,
    "FontAwesome.gavel": FontAwesomeIcons.gavel,
    "FontAwesome.dashboard": FontAwesomeIcons.tachometerAlt,
    "FontAwesome.tachometer": FontAwesomeIcons.tachometerAlt,
    "FontAwesome.comment-o": FontAwesomeIcons.solidComment,
    "FontAwesome.comments-o": FontAwesomeIcons.solidComments,
    "FontAwesome.flash": FontAwesomeIcons.bolt,
    "FontAwesome.bolt": FontAwesomeIcons.bolt,
    "FontAwesome.sitemap": FontAwesomeIcons.sitemap,
    "FontAwesome.umbrella": FontAwesomeIcons.umbrella,
    "FontAwesome.paste": FontAwesomeIcons.paste,
    "FontAwesome.clipboard": FontAwesomeIcons.clipboard,
    "FontAwesome.lightbulb-o": FontAwesomeIcons.solidLightbulb,
    "FontAwesome.exchange": FontAwesomeIcons.exchangeAlt,
    "FontAwesome.cloud-download": FontAwesomeIcons.cloudDownloadAlt,
    "FontAwesome.cloud-upload": FontAwesomeIcons.cloudUploadAlt,
    "FontAwesome.user-md": FontAwesomeIcons.userMd,
    "FontAwesome.stethoscope": FontAwesomeIcons.stethoscope,
    "FontAwesome.suitcase": FontAwesomeIcons.suitcase,
    "FontAwesome.bell-o": FontAwesomeIcons.solidBell,
    "FontAwesome.coffee": FontAwesomeIcons.coffee,
    "FontAwesome.cutlery": FontAwesomeIcons.utensils,
    "FontAwesome.file-text-o": FontAwesomeIcons.solidFileAlt,
    "FontAwesome.building-o": FontAwesomeIcons.solidBuilding,
    "FontAwesome.hospital-o": FontAwesomeIcons.solidHospital,
    "FontAwesome.ambulance": FontAwesomeIcons.ambulance,
    "FontAwesome.medkit": FontAwesomeIcons.medkit,
    "FontAwesome.fighter-jet": FontAwesomeIcons.fighterJet,
    "FontAwesome.beer": FontAwesomeIcons.beer,
    "FontAwesome.h-square": FontAwesomeIcons.hSquare,
    "FontAwesome.plus-square": FontAwesomeIcons.plusSquare,
    "FontAwesome.angle-double-left": FontAwesomeIcons.angleDoubleLeft,
    "FontAwesome.angle-double-right": FontAwesomeIcons.angleDoubleRight,
    "FontAwesome.angle-double-up": FontAwesomeIcons.angleDoubleUp,
    "FontAwesome.angle-double-down": FontAwesomeIcons.angleDoubleDown,
    "FontAwesome.angle-left": FontAwesomeIcons.angleLeft,
    "FontAwesome.angle-right": FontAwesomeIcons.angleRight,
    "FontAwesome.angle-up": FontAwesomeIcons.angleUp,
    "FontAwesome.angle-down": FontAwesomeIcons.angleDown,
    "FontAwesome.desktop": FontAwesomeIcons.desktop,
    "FontAwesome.laptop": FontAwesomeIcons.laptop,
    "FontAwesome.tablet": FontAwesomeIcons.tablet,
    "FontAwesome.mobile-phone": FontAwesomeIcons.mobileAlt,
    "FontAwesome.mobile": FontAwesomeIcons.mobile,
    "FontAwesome.circle-o": FontAwesomeIcons.solidCircle,
    "FontAwesome.quote-left": FontAwesomeIcons.quoteLeft,
    "FontAwesome.quote-right": FontAwesomeIcons.quoteRight,
    "FontAwesome.spinner": FontAwesomeIcons.spinner,
    "FontAwesome.circle": FontAwesomeIcons.circle,
    "FontAwesome.mail-reply": FontAwesomeIcons.reply,
    "FontAwesome.reply": FontAwesomeIcons.reply,
    "FontAwesome.github-alt": FontAwesomeIcons.githubAlt,
    "FontAwesome.folder-o": FontAwesomeIcons.solidFolder,
    "FontAwesome.folder-open-o": FontAwesomeIcons.solidFolderOpen,
    "FontAwesome.smile-o": FontAwesomeIcons.solidSmile,
    "FontAwesome.frown-o": FontAwesomeIcons.solidFrown,
    "FontAwesome.meh-o": FontAwesomeIcons.solidMeh,
    "FontAwesome.gamepad": FontAwesomeIcons.gamepad,
    "FontAwesome.keyboard-o": FontAwesomeIcons.solidKeyboard,
    "FontAwesome.flag-o": FontAwesomeIcons.solidFlag,
    "FontAwesome.flag-checkered": FontAwesomeIcons.flagCheckered,
    "FontAwesome.terminal": FontAwesomeIcons.terminal,
    "FontAwesome.code": FontAwesomeIcons.code,
    "FontAwesome.mail-reply-all": FontAwesomeIcons.replyAll,
    "FontAwesome.reply-all": FontAwesomeIcons.replyAll,
    "FontAwesome.star-half-empty": FontAwesomeIcons.starHalfAlt,
    "FontAwesome.star-half-full": FontAwesomeIcons.starHalfAlt,
    "FontAwesome.star-half-o": FontAwesomeIcons.solidStarHalf,
    "FontAwesome.location-arrow": FontAwesomeIcons.locationArrow,
    "FontAwesome.crop": FontAwesomeIcons.crop,
    "FontAwesome.code-fork": FontAwesomeIcons.codeBranch,
    "FontAwesome.unlink": FontAwesomeIcons.unlink,
    "FontAwesome.chain-broken": FontAwesomeIcons.unlink,
    "FontAwesome.question": FontAwesomeIcons.question,
    "FontAwesome.info": FontAwesomeIcons.info,
    "FontAwesome.exclamation": FontAwesomeIcons.exclamation,
    "FontAwesome.superscript": FontAwesomeIcons.superscript,
    "FontAwesome.subscript": FontAwesomeIcons.subscript,
    "FontAwesome.eraser": FontAwesomeIcons.eraser,
    "FontAwesome.puzzle-piece": FontAwesomeIcons.puzzlePiece,
    "FontAwesome.microphone": FontAwesomeIcons.microphone,
    "FontAwesome.microphone-slash": FontAwesomeIcons.microphoneSlash,
    "FontAwesome.shield": FontAwesomeIcons.shieldAlt,
    "FontAwesome.calendar-o": FontAwesomeIcons.solidCalendar,
    "FontAwesome.fire-extinguisher": FontAwesomeIcons.fireExtinguisher,
    "FontAwesome.rocket": FontAwesomeIcons.rocket,
    "FontAwesome.maxcdn": FontAwesomeIcons.maxcdn,
    "FontAwesome.chevron-circle-left": FontAwesomeIcons.chevronCircleLeft,
    "FontAwesome.chevron-circle-right": FontAwesomeIcons.chevronCircleRight,
    "FontAwesome.chevron-circle-up": FontAwesomeIcons.chevronCircleUp,
    "FontAwesome.chevron-circle-down": FontAwesomeIcons.chevronCircleDown,
    "FontAwesome.html5": FontAwesomeIcons.html5,
    "FontAwesome.css3": FontAwesomeIcons.css3,
    "FontAwesome.anchor": FontAwesomeIcons.anchor,
    "FontAwesome.unlock-alt": FontAwesomeIcons.unlockAlt,
    "FontAwesome.bullseye": FontAwesomeIcons.bullseye,
    "FontAwesome.ellipsis-h": FontAwesomeIcons.ellipsisH,
    "FontAwesome.ellipsis-v": FontAwesomeIcons.ellipsisV,
    "FontAwesome.rss-square": FontAwesomeIcons.rssSquare,
    "FontAwesome.play-circle": FontAwesomeIcons.playCircle,
    "FontAwesome.ticket": FontAwesomeIcons.ticketAlt,
    "FontAwesome.minus-square": FontAwesomeIcons.minusSquare,
    "FontAwesome.minus-square-o": FontAwesomeIcons.solidMinusSquare,
    "FontAwesome.level-up": FontAwesomeIcons.levelUpAlt,
    "FontAwesome.level-down": FontAwesomeIcons.levelDownAlt,
    "FontAwesome.check-square": FontAwesomeIcons.checkSquare,
    "FontAwesome.pencil-square": FontAwesomeIcons.penSquare,
    "FontAwesome.external-link-square": FontAwesomeIcons.externalLinkSquareAlt,
    "FontAwesome.share-square": FontAwesomeIcons.shareSquare,
    "FontAwesome.compass": FontAwesomeIcons.compass,
    "FontAwesome.caret-square-o-down": FontAwesomeIcons.solidCaretSquareDown,
    "FontAwesome.caret-square-o-up": FontAwesomeIcons.solidCaretSquareUp,
    "FontAwesome.caret-square-o-right": FontAwesomeIcons.solidCaretSquareRight,
    "FontAwesome.euro": FontAwesomeIcons.euroSign,
    "FontAwesome.gbp": FontAwesomeIcons.poundSign,
    "FontAwesome.dollar": FontAwesomeIcons.dollarSign,
    "FontAwesome.usd": FontAwesomeIcons.dollarSign,
    "FontAwesome.rupee": FontAwesomeIcons.rupeeSign,
    "FontAwesome.inr": FontAwesomeIcons.rupeeSign,
    "FontAwesome.cny": FontAwesomeIcons.yenSign,
    "FontAwesome.rmb": FontAwesomeIcons.yenSign,
    "FontAwesome.yen": FontAwesomeIcons.yenSign,
    "FontAwesome.jpy": FontAwesomeIcons.yenSign,
    "FontAwesome.ruble": FontAwesomeIcons.rubleSign,
    "FontAwesome.rouble": FontAwesomeIcons.rubleSign,
    "FontAwesome.rub": FontAwesomeIcons.rubleSign,
    "FontAwesome.won": FontAwesomeIcons.wonSign,
    "FontAwesome.krw": FontAwesomeIcons.wonSign,
    "FontAwesome.bitcoin": FontAwesomeIcons.bitcoin,
    "FontAwesome.btc": FontAwesomeIcons.btc,
    "FontAwesome.file": FontAwesomeIcons.file,
    "FontAwesome.file-text": FontAwesomeIcons.fileAlt,
    "FontAwesome.sort-alpha-asc": FontAwesomeIcons.sortAlphaDown,
    "FontAwesome.sort-alpha-desc": FontAwesomeIcons.sortAlphaUp,
    "FontAwesome.sort-amount-asc": FontAwesomeIcons.sortAmountDown,
    "FontAwesome.sort-amount-desc": FontAwesomeIcons.sortAmountUp,
    "FontAwesome.sort-numeric-asc": FontAwesomeIcons.sortNumericDown,
    "FontAwesome.sort-numeric-desc": FontAwesomeIcons.sortNumericUp,
    "FontAwesome.thumbs-up": FontAwesomeIcons.thumbsUp,
    "FontAwesome.thumbs-down": FontAwesomeIcons.thumbsDown,
    "FontAwesome.youtube-square": FontAwesomeIcons.youtubeSquare,
    "FontAwesome.youtube": FontAwesomeIcons.youtube,
    "FontAwesome.xing": FontAwesomeIcons.xing,
    "FontAwesome.xing-square": FontAwesomeIcons.xingSquare,
    "FontAwesome.youtube-play": FontAwesomeIcons.youtube,
    "FontAwesome.dropbox": FontAwesomeIcons.dropbox,
    "FontAwesome.stack-overflow": FontAwesomeIcons.stackOverflow,
    "FontAwesome.instagram": FontAwesomeIcons.instagram,
    "FontAwesome.flickr": FontAwesomeIcons.flickr,
    "FontAwesome.adn": FontAwesomeIcons.adn,
    "FontAwesome.bitbucket": FontAwesomeIcons.bitbucket,
    "FontAwesome.bitbucket-square": FontAwesomeIcons.bitbucket,
    "FontAwesome.tumblr": FontAwesomeIcons.tumblr,
    "FontAwesome.tumblr-square": FontAwesomeIcons.tumblrSquare,
    "FontAwesome.long-arrow-down": FontAwesomeIcons.longArrowAltDown,
    "FontAwesome.long-arrow-up": FontAwesomeIcons.longArrowAltUp,
    "FontAwesome.long-arrow-left": FontAwesomeIcons.longArrowAltLeft,
    "FontAwesome.long-arrow-right": FontAwesomeIcons.longArrowAltRight,
    "FontAwesome.apple": FontAwesomeIcons.apple,
    "FontAwesome.windows": FontAwesomeIcons.windows,
    "FontAwesome.android": FontAwesomeIcons.android,
    "FontAwesome.linux": FontAwesomeIcons.linux,
    "FontAwesome.dribbble": FontAwesomeIcons.dribbble,
    "FontAwesome.skype": FontAwesomeIcons.skype,
    "FontAwesome.foursquare": FontAwesomeIcons.foursquare,
    "FontAwesome.trello": FontAwesomeIcons.trello,
    "FontAwesome.female": FontAwesomeIcons.female,
    "FontAwesome.male": FontAwesomeIcons.male,
    "FontAwesome.gittip": FontAwesomeIcons.gratipay,
    "FontAwesome.gratipay": FontAwesomeIcons.gratipay,
    "FontAwesome.sun-o": FontAwesomeIcons.solidSun,
    "FontAwesome.moon-o": FontAwesomeIcons.solidMoon,
    "FontAwesome.archive": FontAwesomeIcons.archive,
    "FontAwesome.bug": FontAwesomeIcons.bug,
    "FontAwesome.vk": FontAwesomeIcons.vk,
    "FontAwesome.weibo": FontAwesomeIcons.weibo,
    "FontAwesome.renren": FontAwesomeIcons.renren,
    "FontAwesome.pagelines": FontAwesomeIcons.pagelines,
    "FontAwesome.stack-exchange": FontAwesomeIcons.stackExchange,
    "FontAwesome.arrow-circle-o-right": FontAwesomeIcons.solidArrowAltCircleRight,
    "FontAwesome.arrow-circle-o-left": FontAwesomeIcons.solidArrowAltCircleLeft,
    "FontAwesome.caret-square-o-left": FontAwesomeIcons.solidCaretSquareLeft,
    "FontAwesome.dot-circle-o": FontAwesomeIcons.solidDotCircle,
    "FontAwesome.wheelchair": FontAwesomeIcons.wheelchair,
    "FontAwesome.vimeo-square": FontAwesomeIcons.vimeoSquare,
    "FontAwesome.turkish-lira": FontAwesomeIcons.liraSign,
    "FontAwesome.try": FontAwesomeIcons.liraSign,
    "FontAwesome.plus-square-o": FontAwesomeIcons.solidPlusSquare,
    "FontAwesome.space-shuttle": FontAwesomeIcons.spaceShuttle,
    "FontAwesome.slack": FontAwesomeIcons.slack,
    "FontAwesome.envelope-square": FontAwesomeIcons.envelopeSquare,
    "FontAwesome.wordpress": FontAwesomeIcons.wordpress,
    "FontAwesome.openid": FontAwesomeIcons.openid,
    "FontAwesome.institution": FontAwesomeIcons.university,
    "FontAwesome.bank": FontAwesomeIcons.university,
    "FontAwesome.university": FontAwesomeIcons.university,
    "FontAwesome.mortar-board": FontAwesomeIcons.graduationCap,
    "FontAwesome.graduation-cap": FontAwesomeIcons.graduationCap,
    "FontAwesome.yahoo": FontAwesomeIcons.yahoo,
    "FontAwesome.google": FontAwesomeIcons.google,
    "FontAwesome.reddit": FontAwesomeIcons.reddit,
    "FontAwesome.reddit-square": FontAwesomeIcons.redditSquare,
    "FontAwesome.stumbleupon-circle": FontAwesomeIcons.stumbleuponCircle,
    "FontAwesome.stumbleupon": FontAwesomeIcons.stumbleupon,
    "FontAwesome.delicious": FontAwesomeIcons.delicious,
    "FontAwesome.digg": FontAwesomeIcons.digg,
    "FontAwesome.pied-piper": FontAwesomeIcons.piedPiper,
    "FontAwesome.pied-piper-alt": FontAwesomeIcons.piedPiperAlt,
    "FontAwesome.drupal": FontAwesomeIcons.drupal,
    "FontAwesome.joomla": FontAwesomeIcons.joomla,
    "FontAwesome.language": FontAwesomeIcons.language,
    "FontAwesome.fax": FontAwesomeIcons.fax,
    "FontAwesome.building": FontAwesomeIcons.building,
    "FontAwesome.child": FontAwesomeIcons.child,
    "FontAwesome.paw": FontAwesomeIcons.paw,
    "FontAwesome.spoon": FontAwesomeIcons.utensilSpoon,
    "FontAwesome.cube": FontAwesomeIcons.cube,
    "FontAwesome.cubes": FontAwesomeIcons.cubes,
    "FontAwesome.behance": FontAwesomeIcons.behance,
    "FontAwesome.behance-square": FontAwesomeIcons.behanceSquare,
    "FontAwesome.steam": FontAwesomeIcons.steam,
    "FontAwesome.steam-square": FontAwesomeIcons.steamSquare,
    "FontAwesome.recycle": FontAwesomeIcons.recycle,
    "FontAwesome.automobile": FontAwesomeIcons.car,
    "FontAwesome.car": FontAwesomeIcons.car,
    "FontAwesome.cab": FontAwesomeIcons.taxi,
    "FontAwesome.taxi": FontAwesomeIcons.taxi,
    "FontAwesome.tree": FontAwesomeIcons.tree,
    "FontAwesome.spotify": FontAwesomeIcons.spotify,
    "FontAwesome.deviantart": FontAwesomeIcons.deviantart,
    "FontAwesome.soundcloud": FontAwesomeIcons.soundcloud,
    "FontAwesome.database": FontAwesomeIcons.database,
    "FontAwesome.file-pdf-o": FontAwesomeIcons.solidFilePdf,
    "FontAwesome.file-word-o": FontAwesomeIcons.solidFileWord,
    "FontAwesome.file-excel-o": FontAwesomeIcons.solidFileExcel,
    "FontAwesome.file-powerpoint-o": FontAwesomeIcons.solidFilePowerpoint,
    "FontAwesome.file-photo-o": FontAwesomeIcons.solidFileImage,
    "FontAwesome.file-picture-o": FontAwesomeIcons.solidFileImage,
    "FontAwesome.file-image-o": FontAwesomeIcons.solidFileImage,
    "FontAwesome.file-zip-o": FontAwesomeIcons.fileArchive,
    "FontAwesome.file-archive-o": FontAwesomeIcons.solidFileArchive,
    "FontAwesome.file-sound-o": FontAwesomeIcons.solidFileAudio,
    "FontAwesome.file-audio-o": FontAwesomeIcons.solidFileAudio,
    "FontAwesome.file-movie-o": FontAwesomeIcons.solidFileVideo,
    "FontAwesome.file-video-o": FontAwesomeIcons.solidFileVideo,
    "FontAwesome.file-code-o": FontAwesomeIcons.solidFileCode,
    "FontAwesome.vine": FontAwesomeIcons.vine,
    "FontAwesome.codepen": FontAwesomeIcons.codepen,
    "FontAwesome.jsfiddle": FontAwesomeIcons.jsfiddle,
    "FontAwesome.life-bouy": FontAwesomeIcons.lifeRing,
    "FontAwesome.life-buoy": FontAwesomeIcons.lifeRing,
    "FontAwesome.life-saver": FontAwesomeIcons.lifeRing,
    "FontAwesome.support": FontAwesomeIcons.phoneSquare,
    "FontAwesome.life-ring": FontAwesomeIcons.lifeRing,
    "FontAwesome.circle-o-notch": FontAwesomeIcons.circleNotch,
    "FontAwesome.ra": FontAwesomeIcons.rebel,
    "FontAwesome.rebel": FontAwesomeIcons.rebel,
    "FontAwesome.ge": FontAwesomeIcons.empire,
    "FontAwesome.empire": FontAwesomeIcons.empire,
    "FontAwesome.git-square": FontAwesomeIcons.gitSquare,
    "FontAwesome.git": FontAwesomeIcons.git,
    "FontAwesome.y-combinator-square": FontAwesomeIcons.yCombinator,
    "FontAwesome.yc-square": FontAwesomeIcons.hackerNewsSquare,
    "FontAwesome.hacker-news": FontAwesomeIcons.hackerNews,
    "FontAwesome.tencent-weibo": FontAwesomeIcons.tencentWeibo,
    "FontAwesome.qq": FontAwesomeIcons.qq,
    "FontAwesome.wechat": FontAwesomeIcons.weixin,
    "FontAwesome.weixin": FontAwesomeIcons.weixin,
    "FontAwesome.send": FontAwesomeIcons.solidShareSquare,
    "FontAwesome.paper-plane": FontAwesomeIcons.paperPlane,
    "FontAwesome.send-o": FontAwesomeIcons.shareSquare,
    "FontAwesome.paper-plane-o": FontAwesomeIcons.solidPaperPlane,
    "FontAwesome.history": FontAwesomeIcons.history,
    "FontAwesome.circle-thin": FontAwesomeIcons.circle,
    "FontAwesome.header": FontAwesomeIcons.heading,
    "FontAwesome.paragraph": FontAwesomeIcons.paragraph,
    "FontAwesome.sliders": FontAwesomeIcons.slidersH,
    "FontAwesome.share-alt": FontAwesomeIcons.shareAlt,
    "FontAwesome.share-alt-square": FontAwesomeIcons.shareAltSquare,
    "FontAwesome.bomb": FontAwesomeIcons.bomb,
    "FontAwesome.soccer-ball-o": FontAwesomeIcons.solidFutbol,
    "FontAwesome.futbol-o": FontAwesomeIcons.solidFutbol,
    "FontAwesome.tty": FontAwesomeIcons.tty,
    "FontAwesome.binoculars": FontAwesomeIcons.binoculars,
    "FontAwesome.plug": FontAwesomeIcons.plug,
    "FontAwesome.slideshare": FontAwesomeIcons.slideshare,
    "FontAwesome.twitch": FontAwesomeIcons.twitch,
    "FontAwesome.yelp": FontAwesomeIcons.yelp,
    "FontAwesome.newspaper-o": FontAwesomeIcons.solidNewspaper,
    "FontAwesome.wifi": FontAwesomeIcons.wifi,
    "FontAwesome.calculator": FontAwesomeIcons.calculator,
    "FontAwesome.paypal": FontAwesomeIcons.paypal,
    "FontAwesome.google-wallet": FontAwesomeIcons.googleWallet,
    "FontAwesome.cc-visa": FontAwesomeIcons.ccVisa,
    "FontAwesome.cc-mastercard": FontAwesomeIcons.ccMastercard,
    "FontAwesome.cc-discover": FontAwesomeIcons.ccDiscover,
    "FontAwesome.cc-amex": FontAwesomeIcons.ccAmex,
    "FontAwesome.cc-paypal": FontAwesomeIcons.ccPaypal,
    "FontAwesome.cc-stripe": FontAwesomeIcons.ccStripe,
    "FontAwesome.bell-slash": FontAwesomeIcons.bellSlash,
    "FontAwesome.bell-slash-o": FontAwesomeIcons.solidBellSlash,
    "FontAwesome.trash": FontAwesomeIcons.trash,
    "FontAwesome.copyright": FontAwesomeIcons.copyright,
    "FontAwesome.at": FontAwesomeIcons.at,
    "FontAwesome.eyedropper": FontAwesomeIcons.eyeDropper,
    "FontAwesome.paint-brush": FontAwesomeIcons.paintBrush,
    "FontAwesome.birthday-cake": FontAwesomeIcons.birthdayCake,
    "FontAwesome.area-chart": FontAwesomeIcons.chartArea,
    "FontAwesome.pie-chart": FontAwesomeIcons.chartPie,
    "FontAwesome.line-chart": FontAwesomeIcons.chartLine,
    "FontAwesome.lastfm": FontAwesomeIcons.lastfm,
    "FontAwesome.lastfm-square": FontAwesomeIcons.lastfmSquare,
    "FontAwesome.toggle-off": FontAwesomeIcons.toggleOff,
    "FontAwesome.toggle-on": FontAwesomeIcons.toggleOn,
    "FontAwesome.bicycle": FontAwesomeIcons.bicycle,
    "FontAwesome.bus": FontAwesomeIcons.bus,
    "FontAwesome.ioxhost": FontAwesomeIcons.ioxhost,
    "FontAwesome.angellist": FontAwesomeIcons.angellist,
    "FontAwesome.cc": FontAwesomeIcons.closedCaptioning,
    "FontAwesome.shekel": FontAwesomeIcons.shekelSign,
    "FontAwesome.sheqel": FontAwesomeIcons.shekelSign,
    "FontAwesome.ils": FontAwesomeIcons.shekelSign,
    "FontAwesome.meanpath": FontAwesomeIcons.fontAwesome,
    "FontAwesome.buysellads": FontAwesomeIcons.buysellads,
    "FontAwesome.connectdevelop": FontAwesomeIcons.connectdevelop,
    "FontAwesome.dashcube": FontAwesomeIcons.dashcube,
    "FontAwesome.forumbee": FontAwesomeIcons.forumbee,
    "FontAwesome.leanpub": FontAwesomeIcons.leanpub,
    "FontAwesome.sellsy": FontAwesomeIcons.sellsy,
    "FontAwesome.shirtsinbulk": FontAwesomeIcons.shirtsinbulk,
    "FontAwesome.simplybuilt": FontAwesomeIcons.simplybuilt,
    "FontAwesome.skyatlas": FontAwesomeIcons.skyatlas,
    "FontAwesome.cart-plus": FontAwesomeIcons.cartPlus,
    "FontAwesome.cart-arrow-down": FontAwesomeIcons.cartArrowDown,
    "FontAwesome.diamond": FontAwesomeIcons.gem,
    "FontAwesome.ship": FontAwesomeIcons.ship,
    "FontAwesome.user-secret": FontAwesomeIcons.userSecret,
    "FontAwesome.motorcycle": FontAwesomeIcons.motorcycle,
    "FontAwesome.street-view": FontAwesomeIcons.streetView,
    "FontAwesome.heartbeat": FontAwesomeIcons.heartbeat,
    "FontAwesome.venus": FontAwesomeIcons.venus,
    "FontAwesome.mars": FontAwesomeIcons.mars,
    "FontAwesome.mercury": FontAwesomeIcons.mercury,
    "FontAwesome.intersex": FontAwesomeIcons.transgender,
    "FontAwesome.transgender": FontAwesomeIcons.transgender,
    "FontAwesome.transgender-alt": FontAwesomeIcons.transgenderAlt,
    "FontAwesome.venus-double": FontAwesomeIcons.venusDouble,
    "FontAwesome.mars-double": FontAwesomeIcons.marsDouble,
    "FontAwesome.venus-mars": FontAwesomeIcons.venusMars,
    "FontAwesome.mars-stroke": FontAwesomeIcons.marsStroke,
    "FontAwesome.mars-stroke-v": FontAwesomeIcons.marsStrokeV,
    "FontAwesome.mars-stroke-h": FontAwesomeIcons.marsStrokeH,
    "FontAwesome.neuter": FontAwesomeIcons.neuter,
    "FontAwesome.genderless": FontAwesomeIcons.genderless,
    "FontAwesome.facebook-official": FontAwesomeIcons.facebook,
    "FontAwesome.pinterest-p": FontAwesomeIcons.pinterestP,
    "FontAwesome.whatsapp": FontAwesomeIcons.whatsapp,
    "FontAwesome.server": FontAwesomeIcons.server,
    "FontAwesome.user-plus": FontAwesomeIcons.userPlus,
    "FontAwesome.user-times": FontAwesomeIcons.userTimes,
    "FontAwesome.hotel": FontAwesomeIcons.hotel,
    "FontAwesome.bed": FontAwesomeIcons.bed,
    "FontAwesome.viacoin": FontAwesomeIcons.viacoin,
    "FontAwesome.train": FontAwesomeIcons.train,
    "FontAwesome.subway": FontAwesomeIcons.subway,
    "FontAwesome.medium": FontAwesomeIcons.medium,
    "FontAwesome.yc": FontAwesomeIcons.yCombinator,
    "FontAwesome.y-combinator": FontAwesomeIcons.yCombinator,
    "FontAwesome.optin-monster": FontAwesomeIcons.optinMonster,
    "FontAwesome.opencart": FontAwesomeIcons.opencart,
    "FontAwesome.expeditedssl": FontAwesomeIcons.expeditedssl,
    "FontAwesome.battery-4": FontAwesomeIcons.batteryFull,
    "FontAwesome.battery-full": FontAwesomeIcons.batteryFull,
    "FontAwesome.battery-3": FontAwesomeIcons.batteryThreeQuarters,
    "FontAwesome.battery-three-quarters": FontAwesomeIcons.batteryThreeQuarters,
    "FontAwesome.battery-2": FontAwesomeIcons.batteryHalf,
    "FontAwesome.battery-half": FontAwesomeIcons.batteryHalf,
    "FontAwesome.battery-1": FontAwesomeIcons.batteryQuarter,
    "FontAwesome.battery-quarter": FontAwesomeIcons.batteryQuarter,
    "FontAwesome.battery-0": FontAwesomeIcons.batteryEmpty,
    "FontAwesome.battery-empty": FontAwesomeIcons.batteryEmpty,
    "FontAwesome.mouse-pointer": FontAwesomeIcons.mousePointer,
    "FontAwesome.i-cursor": FontAwesomeIcons.iCursor,
    "FontAwesome.object-group": FontAwesomeIcons.objectGroup,
    "FontAwesome.object-ungroup": FontAwesomeIcons.objectUngroup,
    "FontAwesome.sticky-note": FontAwesomeIcons.stickyNote,
    "FontAwesome.sticky-note-o": FontAwesomeIcons.stickyNote,
    "FontAwesome.cc-jcb": FontAwesomeIcons.ccJcb,
    "FontAwesome.cc-diners-club": FontAwesomeIcons.ccDinersClub,
    "FontAwesome.clone": FontAwesomeIcons.clone,
    "FontAwesome.balance-scale": FontAwesomeIcons.balanceScale,
    "FontAwesome.hourglass-o": FontAwesomeIcons.hourglass,
    "FontAwesome.hourglass-1": FontAwesomeIcons.hourglassStart,
    "FontAwesome.hourglass-start": FontAwesomeIcons.hourglassStart,
    "FontAwesome.hourglass-2": FontAwesomeIcons.hourglassHalf,
    "FontAwesome.hourglass-half": FontAwesomeIcons.hourglassHalf,
    "FontAwesome.hourglass-3": FontAwesomeIcons.hourglassEnd,
    "FontAwesome.hourglass-end": FontAwesomeIcons.hourglassEnd,
    "FontAwesome.hourglass": FontAwesomeIcons.hourglass,
    "FontAwesome.hand-grab-o": FontAwesomeIcons.solidHandRock,
    "FontAwesome.hand-rock-o": FontAwesomeIcons.solidHandRock,
    "FontAwesome.hand-stop-o": FontAwesomeIcons.solidHandPaper,
    "FontAwesome.hand-paper-o": FontAwesomeIcons.solidHandPaper,
    "FontAwesome.hand-scissors-o": FontAwesomeIcons.solidHandScissors,
    "FontAwesome.hand-lizard-o": FontAwesomeIcons.solidHandLizard,
    "FontAwesome.hand-spock-o": FontAwesomeIcons.solidHandSpock,
    "FontAwesome.hand-pointer-o": FontAwesomeIcons.solidHandPointer,
    "FontAwesome.hand-peace-o": FontAwesomeIcons.solidHandPeace,
    "FontAwesome.trademark": FontAwesomeIcons.trademark,
    "FontAwesome.registered": FontAwesomeIcons.registered,
    "FontAwesome.creative-commons": FontAwesomeIcons.creativeCommons,
    "FontAwesome.gg": FontAwesomeIcons.gg,
    "FontAwesome.gg-circle": FontAwesomeIcons.ggCircle,
    "FontAwesome.tripadvisor": FontAwesomeIcons.ggCircle,
    "FontAwesome.odnoklassniki": FontAwesomeIcons.odnoklassniki,
    "FontAwesome.odnoklassniki-square": FontAwesomeIcons.odnoklassnikiSquare,
    "FontAwesome.get-pocket": FontAwesomeIcons.getPocket,
    "FontAwesome.wikipedia-w": FontAwesomeIcons.wikipediaW,
    "FontAwesome.safari": FontAwesomeIcons.safari,
    "FontAwesome.chrome": FontAwesomeIcons.chrome,
    "FontAwesome.firefox": FontAwesomeIcons.firefox,
    "FontAwesome.opera": FontAwesomeIcons.opera,
    "FontAwesome.internet-explorer": FontAwesomeIcons.internetExplorer,
    "FontAwesome.tv": FontAwesomeIcons.tv,
    "FontAwesome.television": FontAwesomeIcons.tv,
    "FontAwesome.contao": FontAwesomeIcons.contao,
    "FontAwesome.500px": FontAwesomeIcons.questionCircle,
    "FontAwesome.amazon": FontAwesomeIcons.amazon,
    "FontAwesome.calendar-plus-o": FontAwesomeIcons.solidCalendarPlus,
    "FontAwesome.calendar-minus-o": FontAwesomeIcons.solidCalendarMinus,
    "FontAwesome.calendar-times-o": FontAwesomeIcons.solidCalendarTimes,
    "FontAwesome.calendar-check-o": FontAwesomeIcons.solidCalendarCheck,
    "FontAwesome.industry": FontAwesomeIcons.industry,
    "FontAwesome.map-pin": FontAwesomeIcons.mapPin,
    "FontAwesome.map-signs": FontAwesomeIcons.mapSigns,
    "FontAwesome.map-o": FontAwesomeIcons.solidMap,
    "FontAwesome.map": FontAwesomeIcons.map,
    "FontAwesome.commenting": FontAwesomeIcons.commentDots,
    "FontAwesome.commenting-o": FontAwesomeIcons.solidCommentDots,
    "FontAwesome.houzz": FontAwesomeIcons.houzz,
    "FontAwesome.vimeo": FontAwesomeIcons.vimeo,
    "FontAwesome.black-tie": FontAwesomeIcons.blackTie,
    "FontAwesome.fonticons": FontAwesomeIcons.fonticons,
  };
}
