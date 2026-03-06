import 'package:app_tracking_transparency/app_tracking_transparency.dart';

import '../analytics/analytics_events.dart';
import '../analytics/analytics_service.dart';

class AttTransparencyService {
  AttTransparencyService({required AnalyticsService analyticsService})
    : _analyticsService = analyticsService;

  final AnalyticsService _analyticsService;

  Future<void> requestIfNeeded() async {
    try {
      final currentStatus =
          await AppTrackingTransparency.trackingAuthorizationStatus;

      if (currentStatus == TrackingStatus.notDetermined) {
        final requestedStatus =
            await AppTrackingTransparency.requestTrackingAuthorization();
        await _logStatus(requestedStatus, requestedFromPrompt: true);
        return;
      }

      await _logStatus(currentStatus, requestedFromPrompt: false);
    } catch (error) {
      await _analyticsService.logEvent(
        AnalyticsEvents.attRequestFailed,
        parameters: {'error': error.toString()},
      );
    }
  }

  Future<void> _logStatus(
    TrackingStatus status, {
    required bool requestedFromPrompt,
  }) {
    return _analyticsService.logEvent(
      AnalyticsEvents.attStatusUpdated,
      parameters: {
        'status': status.name,
        'requested_from_prompt': requestedFromPrompt,
      },
    );
  }
}
