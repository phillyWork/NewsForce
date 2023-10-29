//
//  enum+MappingURLPress.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/13.
//

import Foundation

enum MappingURLPress: String, CaseIterable {
    
    case maekyung = "mk.co.kr"
    case hankyung = "hankyung.com"
    case seoul = "seoul.co.kr"
    case newsis = "newsis.com"
    case yeonhap = "yna.co.kr"
    case hani = "hani.co.kr"
    case khan = "khan.co.kr"
    case iNews24 = "inews24.com"
    case hkilbo = "hankookilbo.com"
    case news1 = "news1.kr"
    case theFact = "tf.co.kr"
    case seoulEconomy = "www.sedaily.com"
    case asiaEconomy = "asiae.co.kr"
    case munhwa = "munhwa.com"
    case mhns = "mhns.co.kr"
    case zdnetKor = "zdnet.co.kr"
    case gukje = "gukjenews.com"
    case kukje = "kookje.co.kr"
    case etnews = "etnews.com"
    case financial = "fnnews.com"
    case dailian = "dailian.co.kr"
    case noCut = "nocutnews.co.kr"
    case daehan = "dnews.co.kr"
    case eDaily = "edaily.co.kr"
    case starNews = "starnewskorea.com"
    case segye = "segye.com"
    case heraldEco = "news.heraldcorp.com"
    case doctorsTimes = "doctorstimes.com"
    case eToday = "etoday.co.kr"
    case kjDaily = "kjdaily.com"
    case kookmin = "kmib.co.kr"
    case donga = "donga.com"
    case chosun = "chosun.com"
    case joongang = "joongang.co.kr"
    case moneyToday = "mt.co.kr"
    case bizWatch = "bizwatch.co.kr"
    case joseDaily = "joseilbo.com"
    case moneyS = "moneys.co.kr"
    case mediaToday = "mediatoday.co.kr"
    case ohMyNews = "ohmynews.com"
    case pressian = "pressian.com"
    case digitalDaily = "ddaily.co.kr"
    case digitalTimes = "dt.co.kr"
    case bloter = "bloter.net"
    case thescoop = "thescoop.co.kr"
    case ladyKhan = "lady.khan.co.kr"
    case sisaIn = "sisain.co.kr"
    case sisaJournal = "sisajournal.com"
    case monthlyMountain = "san.chosun.com"
    case economistKor = "economist.co.kr"
    case journalists = "journalist.or.kr"
    case newsTapa = "newstapa.org"
    case dongaScience = "dongascience.com"
    case womenNews = "womennews.co.kr"
    case ilda = "ildaro.com"
    case koreaJoongangDaily = "koreajoongangdaily.joins.com"
    case koreaHerald = "news.koreaherald.com"
    case kormedi = "kormedi.com"
    case gangwon = "kado.net"
    case gangwonDaily = "kwnews.co.kr"
    case gyeonggi = "kyeonggi.com"
    case farmer = "nongmin.com"
    case daejeonDaily = "daejonilbo.com"
    case dailyNews = "imaeil.com"
    case busanDaily = "busan.com"
    case sbs = "sbs.co.kr"
    case mbc = "mbc.co.kr"
    case ytn = "ytn.co.kr"
    case tvChosun = "tvchosun.com"
    case kbs = "kbs.co.kr"
    case btvCh1 = "ch1.skbroadband.com"
    case jtbc = "jtbc.co.kr"
    case yeonhaptv = "yonhapnewstv.co.kr"
    case channelA = "ichannela.com"
    case hkEconomyTV = "wowtv.co.kr"
    case mbn = "mbn.co.kr"
    case daeguMBC = "dgmbc.com"
    case jeonjuMBC = "jmbc.co.kr"
    case cheongjuBroadcast = "cjb.co.kr"
    case jibs = "jibs.co.kr"
    case kbc = "ikbc.co.kr"
    
    case abc = "abcnews.go.com"
    case nytimes = "nytimes.com"
    case thenewyorker = "newyorker.com"
    case cnn = "cnn.com"
    case economist = "economist.com"
    case guardian = "theguardian.com"
    case independentUK = "independent.co.uk"
    case financialTimesUK = "www.ft.com"
    case washingtonPost = "washingtonpost.com"
    case apNews = "apnews.com"
    case philadelphiaInquirer = "inquirer.com"
    case laTimes = "latimes.com"
    case nbc = "nbcnews.com"
    case cnbc = "cnbc.com"
    case sunSentinel = "sun-sentinel.com"
    case bbc = "bbc.co"
    case fox = "foxnews.com"
    case nyPost = "nypost.com"
    case wallStreetJournal = "wsj.com"
    case rollingStone = "rollingstone.co"
    case huffPost = "huffpost.com"
    case forbes = "forbes.com"
    case bloomberg = "bloomberg.com"
    case physOrg = "phys.org"
    case nyDailylNews = "nydailynews.com"
    case bostonGlobe = "bostonglobe.com"
    case yahooNews = "yahoo.com"
    case investingCom = "investing.com"
    case essentiallySports = "essentiallysports.com"
    case seekingAlpha = "seekingalpha.com"
    case completeSports = "completesports.com"
    case msn = "msn.com"
    case dailyMail = "dailymail.co.uk"
    case googleNews = "news.google.com"
    case usaToday = "usatoday.com"
    case theVerge = "theverge.com"
    case espn = "espn.com"
    
    
    var pressName: String {
        switch self {
        case .maekyung:
            return "매일경제"
        case .hankyung:
            return "한국경제"
        case .hkEconomyTV:
            return "한국경제TV"
        case .seoul:
            return "서울신문"
        case .newsis:
            return "뉴시스"
        case .yeonhap:
            return "연합뉴스"
        case .yeonhaptv:
            return "연합뉴스TV"
        case .sbs:
            return "SBS"
        case .hani:
            return "한겨레"
        case .ladyKhan:
            return "레이디경향"
        case .khan:
            return "경향신문"
        case .iNews24:
            return "아이뉴스24"
        case .ytn:
            return "YTN"
        case .hkilbo:
            return "한국일보"
        case .news1:
            return "뉴스1"
        case .theFact:
            return "더팩트"
        case .seoulEconomy:
            return "서울경제"
        case .asiaEconomy:
            return "아시아경제"
        case .munhwa:
            return "문화일보"
        case .tvChosun:
            return "TV조선"
        case .monthlyMountain:
            return "월간 산"
        case .chosun:
            return "조선일보"
        case .kbs:
            return "KBS"
        case .zdnetKor:
            return "지디넷코리아"
        case .kukje:
            return "국제신문"
        case .jeonjuMBC:
            return "전주MBC"
        case .mbc:
            return "MBC"
        case .etnews:
            return "전자신문"
        case .btvCh1:
            return "Btv 케이블 채널 1번"
        case .financial:
            return "파이낸셜뉴스"
        case .dailian:
            return "데일리안"
        case .noCut:
            return "노컷뉴스"
        case .daehan:
            return "대한경제"
        case .eDaily:
            return "이데일리"
        case .starNews:
            return "스타뉴스"
        case .segye:
            return "세계일보"
        case .heraldEco:
            return "헤럴드경제"
        case .doctorsTimes:
            return "의사신문"
        case .eToday:
            return "이투데이"
        case .kjDaily:
            return "광주매일신문"
        case .jtbc:
            return "JTBC"
        case .kookmin:
            return "국민일보"
        case .dongaScience:
            return "동아사이언스"
        case .donga:
            return "동아일보"
        case .joongang:
            return "중앙일보"
        case .channelA:
            return "채널A"
        case .mbn:
            return "MBN"
        case .moneyToday:
            return "머니투데이"
        case .bizWatch:
            return "비즈워치"
        case .joseDaily:
            return "조세일보"
        case .moneyS:
            return "머니S"
        case .mediaToday:
            return "미디어오늘"
        case .ohMyNews:
            return "오마이뉴스"
        case .pressian:
            return "프레시안"
        case .digitalDaily:
            return "디지털데일리"
        case .digitalTimes:
            return "디지털타임스"
        case .bloter:
            return "블로터"
        case .thescoop:
            return "더스쿠프"
        case .sisaIn:
            return "시사IN"
        case .sisaJournal:
            return "시사저널"
        case .economistKor:
            return "이코노미스트"
        case .journalists:
            return "한국기자협회"
        case .farmer:
            return "농민신문"
        case .newsTapa:
            return "뉴스타파"
        case .womenNews:
            return "여성신문"
        case .ilda:
            return "일다"
        case .koreaJoongangDaily:
            return "Korea JoongAng Daily"
        case .koreaHerald:
            return "Korea Herald"
        case .kormedi:
            return "코메디닷컴"
        case .gangwon:
            return "강원도민일보"
        case .gangwonDaily:
            return "강원일보"
        case .gyeonggi:
            return "경기일보"
        case .daeguMBC:
            return "대구MBC"
        case .daejeonDaily:
            return "대전일보"
        case .dailyNews:
            return "매일신문"
        case .busanDaily:
            return "부산일보"
        case .cheongjuBroadcast:
            return "CJB청주방송"
        case .jibs:
            return "JIBS"
        case .kbc:
            return "KBC광주방송"
        case .mhns:
            return "문화뉴스"
        case .gukje:
            return "국제뉴스"
        case .abc:
            return "ABC News"
        case .nytimes:
            return "The New York Times"
        case .thenewyorker:
            return "The New Yorker"
        case .cnn:
            return "CNN"
        case .economist:
            return "The Economist"
        case .guardian:
            return "The Guardian"
        case .independentUK:
            return "Independent"
        case .financialTimesUK:
            return "Financial Times"
        case .washingtonPost:
            return "The Washington Post"
        case .apNews:
            return "AP"
        case .philadelphiaInquirer:
            return "The Philadelphia Inquirer"
        case .laTimes:
            return "Los Angeles Times"
        case .nbc, .cnbc:
            return "NBC"
        case .sunSentinel:
            return "Sun Sentinel"
        case .bbc:
            return "BBC News"
        case .fox:
            return "Fox News"
        case .nyPost:
            return "New York Post"
        case .wallStreetJournal:
            return "The Wall Street Journal"
        case .rollingStone:
            return "RollingStone"
        case .huffPost:
            return "HuffPost"
        case .forbes:
            return "Forbes"
        case .bloomberg:
            return "Bloomberg"
        case .physOrg:
            return "Phys.org"
        case .nyDailylNews:
            return "New York Daily News"
        case .bostonGlobe:
            return "The Boston Globe"
        case .yahooNews:
            return "Yahoo"
        case .investingCom:
            return "Investing.com"
        case .essentiallySports:
            return "EssentiallySports"
        case .seekingAlpha:
            return "Seeking Alpha"
        case .completeSports:
            return "Complete Sports"
        case .msn:
            return "MSN"
        case .dailyMail:
            return "Daily Mail"
        case .googleNews:
            return "Google News"
        case .usaToday:
            return "USA Today"
        case .theVerge:
            return "The Verge"
        case .espn:
            return "ESPN"
            
            
            
            
            
            
        }
    }
    
}
