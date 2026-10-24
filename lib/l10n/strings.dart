/// Every piece of on-screen text, in English and Hindi. The app shows one
/// language at a time; review Hindi wording here in one place.
class Strings {
  const Strings(this.hindi);

  final bool hindi;

  String _t(String en, String hi) => hindi ? hi : en;

  // ---------- App ----------
  String get appName => _t('Jan Awaaz', 'जन आवाज़');
  String get tagline => _t('Your ward, your voice', 'आपका वार्ड, आपकी आवाज़');
  String get constituency => _t('Mirzapur (AC 396)', 'मिर्ज़ापुर (विधानसभा 396)');

  // ---------- Onboarding ----------
  String get whoIsUsing => _t('Who is using the app?', 'ऐप कौन इस्तेमाल कर रहा है?');
  String get profileJanta => _t('Janta (Public)', 'जनता');
  String get profileJantaDesc =>
      _t("See your ward's complaints and the manifesto", 'अपने वार्ड की शिकायतें और घोषणापत्र देखें');
  String get profileVolunteer => _t('Volunteer', 'स्वयंसेवक');
  String get profileVolunteerDesc =>
      _t('Take household surveys and register complaints', 'घर-घर सर्वे करें और शिकायतें दर्ज करें');
  String get profileAdmin => _t('Leader (Admin)', 'नेता (एडमिन)');
  String get profileAdminDesc => _t('See insights across all wards', 'सभी वार्डों की पूरी जानकारी देखें');
  String get demoProfilesNote =>
      _t('Demo: pick a profile. Login will be added later.', 'डेमो: प्रोफ़ाइल चुनें। लॉगिन बाद में जोड़ा जाएगा।');
  String get switchProfile => _t('Switch profile', 'प्रोफ़ाइल बदलें');
  String get switchLanguage => _t('हिन्दी', 'English');

  // ---------- Common ----------
  String ward(int n) => _t('Ward $n', 'वार्ड $n');
  String get selectYourWard => _t('Select your ward number', 'अपना वार्ड नंबर चुनें');
  String get retry => _t('Try again', 'फिर कोशिश करें');
  String get cancel => _t('Cancel', 'रद्द करें');
  String get save => _t('Save', 'सहेजें');
  String get next => _t('Next', 'आगे');
  String get back => _t('Back', 'पीछे');
  String get done => _t('Done', 'हो गया');
  String get couldNotLoad =>
      _t('Could not load. Check the internet connection.', 'लोड नहीं हो सका। इंटरनेट कनेक्शन जाँचें।');
  String get somethingWentWrong => _t('Something went wrong', 'कुछ गड़बड़ हो गई');
  String get camera => _t('Camera', 'कैमरा');
  String get gallery => _t('Gallery', 'गैलरी');
  String get uploading => _t('Uploading…', 'अपलोड हो रहा है…');
  String get tapToExpand => _t('Tap to open the full map', 'पूरा नक्शा खोलने के लिए टैप करें');
  String daysAgo(int days) => days <= 0
      ? _t('Today', 'आज')
      : days == 1
          ? _t('Yesterday', 'कल')
          : _t('$days days ago', '$days दिन पहले');

  // ---------- Complaints (tickets) ----------
  String get complaints => _t('Complaints', 'शिकायतें');
  String get total => _t('Total', 'कुल');
  String get notStarted => _t('Not started', 'काम शुरू नहीं');
  String get inProgress => _t('In progress', 'काम जारी');
  String get completed => _t('Completed', 'पूरा हुआ');
  String percentCompleted(int p) => _t('$p% completed', '$p% पूरा हुआ');
  String get byProblemType => _t('By problem type', 'समस्या के प्रकार के अनुसार');
  String pendingDone(int pending, int done) => _t('$pending pending · $done done', '$pending बाकी · $done पूरी');
  String get complaintMap => _t('Complaints in this ward', 'इस वार्ड की शिकायतें');
  String get noComplaintsYet => _t('No complaints in this ward yet.', 'इस वार्ड में अभी कोई शिकायत नहीं।');
  String get privacyNote => _t('Only ward totals are shown. No names, phone numbers or addresses.',
      'केवल वार्ड के कुल आँकड़े दिखाए जाते हैं। कोई नाम, फ़ोन नंबर या पता नहीं।');

  // ---------- Survey results on the ward page ----------
  String get whatHouseholdsSaid => _t('What households said', 'घरों ने क्या कहा');
  String householdsShared(int n) =>
      _t('$n households shared their experience', '$n घरों ने अपना अनुभव बताया');
  String notEnoughSurveys(int n, int min) => _t('Survey results appear once $min households have answered ($n so far).',
      'सर्वे के नतीजे $min घरों के जवाब देने के बाद दिखेंगे (अभी तक $n)।');
  String seriousPct(int p) => _t('$p% serious', '$p% गंभीर');
  String get good => _t('Good', 'ठीक है');
  String get needsAttention => _t('Needs attention', 'ध्यान चाहिए');
  String get serious => _t('Serious', 'गंभीर');

  // ---------- Janta ----------
  String get myWard => _t('My ward', 'मेरा वार्ड');
  String get manifesto => _t('Manifesto', 'घोषणापत्र');
  String get downloadPdf => _t('Download PDF', 'पीडीएफ़ डाउनलोड करें');
  String get pdfSaved => _t('Manifesto PDF saved', 'घोषणापत्र की पीडीएफ़ सहेजी गई');
  String get draft => _t('Draft', 'प्रारूप');

  // ---------- Volunteer home ----------
  String get home => _t('Home', 'होम');
  String get todaysDuty => _t("Today's duty", 'आज की ड्यूटी');
  String get dutyWard => _t('Ward on duty', 'ड्यूटी वाला वार्ड');
  String surveysToday(int n) => _t(n == 1 ? '1 survey today' : '$n surveys today', 'आज $n सर्वे');
  String get startSurvey => _t('Start a survey', 'सर्वे शुरू करें');
  String get startSurveyHint => _t('25 questions, about 8 minutes. Each answer is Green, Yellow or Red.',
      '25 सवाल, लगभग 8 मिनट। हर जवाब हरा, पीला या लाल।');
  String get newComplaint => _t('New complaint', 'नई शिकायत');
  String get newComplaintHint =>
      _t('Register a problem with a photo and location', 'फ़ोटो और लोकेशन के साथ समस्या दर्ज करें');
  String get myRecentSurveys => _t('My recent surveys', 'मेरे हाल के सर्वे');
  String get noSurveysYet => _t('No surveys yet.', 'अभी कोई सर्वे नहीं।');

  // ---------- GPS ----------
  String get checkingLocation => _t('Checking location…', 'लोकेशन जाँची जा रही है…');
  String distance(int meters) => meters >= 1000
      ? _t('${(meters / 1000).toStringAsFixed(1)} km', '${(meters / 1000).toStringAsFixed(1)} किमी.')
      : _t('$meters m', '$meters मी.');
  String insideWard(int ward, int meters) =>
      _t('Inside Ward $ward · ${distance(meters)} from centre', 'वार्ड $ward के अंदर · केंद्र से ${distance(meters)}');
  String outsideWard(int ward, int meters) =>
      _t('Outside Ward $ward · ${distance(meters)} from centre', 'वार्ड $ward से बाहर · केंद्र से ${distance(meters)}');
  String get locationOff => _t('Turn on location (GPS) on the phone', 'फ़ोन में लोकेशन (GPS) चालू करें');
  String get locationDenied => _t('Location permission is needed', 'लोकेशन की अनुमति ज़रूरी है');
  String get locationTimeout => _t('Could not get a GPS fix. Try again outdoors.',
      'GPS नहीं मिल पाया। खुली जगह में फिर कोशिश करें।');
  String get useDemoLocation => _t('Demo location (Mirzapur)', 'डेमो लोकेशन (मिर्ज़ापुर)');
  String get refreshLocation => _t('Refresh location', 'लोकेशन दोबारा लें');
  String get loggedInsideWard => _t('Logged inside the ward', 'वार्ड के अंदर दर्ज');
  String get loggedOutsideWard => _t('Logged outside the ward', 'वार्ड से बाहर दर्ज');
  String get noLocationCaptured => _t('No location captured', 'लोकेशन दर्ज नहीं');

  // ---------- Household form ----------
  String get household => _t('Household', 'परिवार');
  String get respondentName => _t('Name', 'नाम');
  String get age => _t('Age', 'उम्र');
  String get gender => _t('Gender', 'लिंग');
  String get female => _t('Woman', 'महिला');
  String get male => _t('Man', 'पुरुष');
  String get otherGender => _t('Other', 'अन्य');
  String get mobileOptional => _t('Mobile (optional)', 'मोबाइल (वैकल्पिक)');
  String get occupation => _t('Main occupation', 'मुख्य व्यवसाय');
  String get occupationHint => _t('e.g. weaver, farmer, shopkeeper', 'जैसे बुनकर, किसान, दुकानदार');
  String get consentRequired => _t(
      'Required. The respondent agrees to answer and be counted in ward totals. Name and mobile are never shown publicly.',
      'आवश्यक। उत्तरदाता जवाब देने और वार्ड के कुल आँकड़ों में गिने जाने के लिए सहमत है। नाम और मोबाइल कभी सार्वजनिक नहीं किए जाते।');
  String get consentWhatsapp => _t(
      'Optional. The respondent agrees to WhatsApp updates about their ward and can stop them any time.',
      'वैकल्पिक। उत्तरदाता अपने वार्ड की जानकारी व्हाट्सऐप पर पाने के लिए सहमत है और कभी भी बंद करवा सकता है।');
  String get startQuestions => _t('Start questions', 'सवाल शुरू करें');
  String get consentNeeded => _t('Consent is required to continue.', 'आगे बढ़ने के लिए सहमति आवश्यक है।');

  // ---------- Questions ----------
  String partLabel(String part) => switch (part) {
        'MICRO' => _t('Part 1 · Daily living', 'भाग 1 · रोज़मर्रा की ज़िंदगी'),
        'MESO' => _t('Part 2 · Community and economy', 'भाग 2 · समुदाय और अर्थव्यवस्था'),
        _ => _t('Part 3 · Governance', 'भाग 3 · शासन'),
      };
  String get notApplicable => _t('Not applicable to this household', 'इस घर पर लागू नहीं');
  String get addPhoto => _t('Add photo', 'फ़ोटो जोड़ें');
  String get photoAdded => _t('Photo added', 'फ़ोटो जुड़ गई');
  String get recordVoice => _t('Voice note (30 s)', 'आवाज़ रिकॉर्ड करें (30 सेकंड)');
  String recordingSeconds(int s) => _t('Recording… $s s · tap to stop', 'रिकॉर्डिंग… $s सेकंड · रोकने के लिए टैप करें');
  String get voiceAdded => _t('Voice note added', 'आवाज़ जुड़ गई');
  String get microphoneDenied => _t('Microphone permission is needed', 'माइक्रोफ़ोन की अनुमति ज़रूरी है');
  String get chooseAnAnswer => _t('Choose an answer to continue', 'आगे बढ़ने के लिए जवाब चुनें');
  String get evidenceHint =>
      _t('Add a photo or a short voice note as proof (optional).', 'सबूत के लिए फ़ोटो या छोटी आवाज़ जोड़ें (वैकल्पिक)।');

  // ---------- Priorities and submit ----------
  String get topPriorities => _t('Top 3 priorities', 'सबसे ज़रूरी 3 मुद्दे');
  String get topPrioritiesHint => _t('Ask: which three should be fixed first? Tap them in order.',
      'पूछें: सबसे पहले कौन-से तीन ठीक होने चाहिए? क्रम से टैप करें।');
  String get noIssuesToRank =>
      _t('This household rated nothing Red or Yellow.', 'इस घर ने किसी मुद्दे को लाल या पीला नहीं बताया।');
  String get submitSurvey => _t('Submit survey', 'सर्वे जमा करें');
  String get submitting => _t('Submitting…', 'जमा हो रहा है…');

  // ---------- Receipt ----------
  String get receiptTitle => _t('JAN AWAAZ: MIRZAPUR', 'जन आवाज़: मिर्ज़ापुर');
  String get issuesEvaluated => _t('Issues evaluated', 'जाँचे गए मुद्दे');
  String get greenSatisfied => _t('Green (satisfied)', 'हरा (संतुष्ट)');
  String get yellowIncomplete => _t('Yellow (incomplete)', 'पीला (अधूरा)');
  String get redSevere => _t('Red (severe)', 'लाल (गंभीर)');
  String get notApplicableShort => _t('Not applicable', 'लागू नहीं');
  String get citizenPriorities => _t('Top 3 citizen priorities', 'नागरिक की 3 प्राथमिकताएँ');
  String get receiptId => _t('Receipt ID', 'रसीद संख्या');
  String get receiptPromise =>
      _t('Ward totals will be published on the public page.', 'वार्ड के कुल आँकड़े सार्वजनिक पेज पर प्रकाशित किए जाएँगे।');
  String get whatsappPreview => _t('WhatsApp message preview', 'व्हाट्सऐप संदेश का नमूना');
  String whatsappMessage(String name, String ward, String issue) => _t(
      'Thank you $name ji. Jan Awaaz has recorded that $issue is a serious problem in $ward. You will get updates about your ward here.',
      'धन्यवाद $name जी। जन आवाज़ ने दर्ज किया है कि $ward में $issue एक गंभीर समस्या है। आपके वार्ड की जानकारी आपको यहीं मिलती रहेगी।');
  String get surveySaved => _t('Survey saved', 'सर्वे सहेजा गया');

  // ---------- New complaint ----------
  String get whatIsTheProblem =>
      _t('What is the problem? Choose one or more.', 'समस्या क्या है? एक या अधिक चुनें।');
  String selectedCount(int n) => _t('$n selected', '$n चुने गए');
  String get oneTicketPerType =>
      _t('Each problem type gets its own complaint number.', 'हर समस्या के लिए अलग शिकायत संख्या बनती है।');
  String get description => _t('Description', 'विवरण');
  String get descriptionHint => _t('What exactly is wrong, and since when?', 'क्या खराब है, और कब से?');
  String get landmark => _t('Landmark', 'पास की पहचान');
  String get landmarkHint => _t('e.g. near the primary school', 'जैसे प्राथमिक विद्यालय के पास');
  String get residentNameOptional => _t('Resident name (optional)', 'निवासी का नाम (वैकल्पिक)');
  String get residentMobileOptional => _t('Resident mobile (optional)', 'निवासी का मोबाइल (वैकल्पिक)');
  String get location => _t('Location', 'लोकेशन');
  String get photo => _t('Photo', 'फ़ोटो');
  String get submitComplaint => _t('Register complaint', 'शिकायत दर्ज करें');
  String get chooseProblemType => _t('Choose at least one problem type.', 'कम से कम एक समस्या चुनें।');
  String complaintsRegistered(int n) => n == 1
      ? _t('Complaint registered', 'शिकायत दर्ज हुई')
      : _t('$n complaints registered', '$n शिकायतें दर्ज हुईं');
  String get shareNumberWithResident =>
      _t('Share these numbers with the resident.', 'ये नंबर निवासी को बता दें।');

  // ---------- Complaint list and detail ----------
  String get searchByNumber => _t('Search by complaint number', 'शिकायत संख्या से खोजें');
  String get all => _t('All', 'सभी');
  String get allWards => _t('All wards', 'सभी वार्ड');
  String get noComplaintsHere => _t('No complaints here.', 'यहाँ कोई शिकायत नहीं।');
  String get history => _t('History', 'इतिहास');
  String get markInProgress => _t('Mark in progress', 'काम जारी करें');
  String get markCompleted => _t('Mark completed', 'पूरा हुआ दर्ज करें');
  String get noteOptional => _t('Note (optional)', 'टिप्पणी (वैकल्पिक)');
  String get edit => _t('Edit', 'बदलें');
  String get editComplaint => _t('Edit complaint', 'शिकायत बदलें');
  String get problemType => _t('Problem type', 'समस्या का प्रकार');
  String get resident => _t('Resident', 'निवासी');
  String get statusUpdated => _t('Status updated', 'स्थिति अपडेट हुई');
  String get saved => _t('Saved', 'सहेजा गया');

  // ---------- Admin ----------
  String get overview => _t('Overview', 'सारांश');
  String get map => _t('Map', 'नक्शा');
  String get issues => _t('Issues', 'मुद्दे');
  String get checks => _t('Checks', 'जाँच');
  String get householdsSurveyed => _t('Households surveyed', 'सर्वे किए गए घर');
  String ofTarget(int t) => _t('of $t target', '$t के लक्ष्य में से');
  String get openComplaints => _t('Open complaints', 'खुली शिकायतें');
  String get avgDaysToResolve => _t('Avg. days to resolve', 'निपटारे में औसत दिन');
  String get volunteers => _t('Volunteers', 'स्वयंसेवक');
  String get today => _t('Today', 'आज');
  String todayActivity(int surveys, int tickets) => _t(
      '$surveys ${surveys == 1 ? 'survey' : 'surveys'} · $tickets ${tickets == 1 ? 'complaint' : 'complaints'}',
      '$surveys सर्वे · $tickets ${tickets == 1 ? 'शिकायत' : 'शिकायतें'}');
  String wardRowLine(int total, int open, int flagged) => _t(
      '$total complaints · $open open${flagged > 0 ? ' · $flagged flagged' : ''}',
      '$total शिकायतें · $open खुली${flagged > 0 ? ' · $flagged संदिग्ध' : ''}');
  String get flaggedSurveys => _t('Flagged surveys', 'संदिग्ध सर्वे');
  String get topSeriousIssues => _t('Top 5 serious issues, whole seat', 'पूरी सीट के 5 सबसे गंभीर मुद्दे');
  String get wardsTitle => _t('Wards', 'वार्ड');
  String get tapWardForDetail => _t('Tap a ward for full details', 'पूरी जानकारी के लिए वार्ड पर टैप करें');
  String surveyedOf(int done, int target) => _t('$done/$target surveyed', '$done/$target सर्वे');
  String volunteersCount(int n) => _t('$n volunteers', '$n स्वयंसेवक');
  String get volunteerActivity => _t('Volunteer activity', 'स्वयंसेवकों का काम');
  String activityLine(int surveys, int tickets, int flagged) => _t(
      '$surveys surveys · $tickets complaints · $flagged flagged',
      '$surveys सर्वे · $tickets शिकायतें · $flagged संदिग्ध');
  String lastActive(String when) => _t('Last active: $when', 'आख़िरी बार सक्रिय: $when');
  String get noActivityYet => _t('No activity yet', 'अभी तक कोई काम नहीं');
  String get recentComplaints => _t('Recent complaints', 'हाल की शिकायतें');
  String get issueHeatmap => _t('Serious-issue heatmap', 'गंभीर मुद्दों का हीटमैप');
  String get heatmapHint => _t('% of households rating each issue Red, by ward. Darker means worse.',
      'हर वार्ड में किसी मुद्दे को लाल बताने वाले घरों का %। गहरा रंग यानी ज़्यादा गंभीर।');
  String get mapHint => _t('Circle colour shows how many complaints are open in each ward.',
      'घेरे का रंग बताता है कि हर वार्ड में कितनी शिकायतें खुली हैं।');
  String get showSurveyLocations => _t('Survey locations', 'सर्वे की जगहें');
  String get qualityHint => _t('Surveys that may need a check: filed outside the assigned ward, or finished too fast.',
      'जिन सर्वे की जाँच ज़रूरी हो सकती है: वार्ड से बाहर भरे गए, या बहुत जल्दी पूरे हुए।');
  String get filedOutsideWard => _t('Filed outside the ward', 'वार्ड से बाहर भरा गया');
  String finishedTooFast(int minSeconds) =>
      _t('Finished in under ${minSeconds ~/ 60} min', '${minSeconds ~/ 60} मिनट से कम में पूरा');
  String metersFromCentre(int m) => _t('${distance(m)} from ward centre', 'वार्ड केंद्र से ${distance(m)}');
  String minutesTaken(int seconds) =>
      _t('${(seconds / 60).toStringAsFixed(1)} min', '${(seconds / 60).toStringAsFixed(1)} मिनट');
  String get nothingFlagged => _t('No surveys flagged.', 'कोई संदिग्ध सर्वे नहीं।');
}
