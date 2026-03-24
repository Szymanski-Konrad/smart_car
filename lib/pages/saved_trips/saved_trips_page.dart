import 'package:flutter/material.dart';
import 'package:smart_car/services/trip_storage.dart';

class SavedTripsPage extends StatefulWidget {
  const SavedTripsPage({super.key});

  @override
  State<SavedTripsPage> createState() => _SavedTripsPageState();
}

class _SavedTripsPageState extends State<SavedTripsPage> {
  List<SavedTripInfo> _trips = [];
  bool _isLoading = true;
  TripStorageStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    try {
      final trips = await TripStorage.instance.getSavedTrips();
      final stats = await TripStorage.instance.getStats();
      setState(() {
        _trips = trips;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Błąd wczytywania: $e')));
      }
    }
  }

  Future<void> _importTrip() async {
    try {
      final trip = await TripStorage.instance.importTrip();
      if (trip != null) {
        await _loadTrips();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Przejazd zaimportowany')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Błąd importu: $e')));
      }
    }
  }

  Future<void> _deleteTrip(SavedTripInfo trip) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Usuń przejazd'),
        content: Text(
          'Czy na pewno usunąć przejazd z ${trip.startTimeFormatted}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TripStorage.instance.deleteTrip(trip.path);
      await _loadTrips();
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wyczyść wszystko'),
        content: const Text(
          'Czy na pewno usunąć wszystkie zapisane przejazdy?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Usuń wszystko'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TripStorage.instance.clearAllTrips();
      await _loadTrips();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zapisane przejazdy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Importuj przejazd',
            onPressed: _importTrip,
          ),
          if (_trips.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Wyczyść wszystko',
              onPressed: _clearAll,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
            onPressed: _loadTrips,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trips.isEmpty
          ? _buildEmptyState()
          : _buildTripsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route_outlined,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Brak zapisanych przejazdów',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Przejazdy będą zapisywane automatycznie\npo zakończeniu jazdy',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _importTrip,
            icon: const Icon(Icons.file_download),
            label: const Text('Importuj przejazd'),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList() {
    return Column(
      children: [
        if (_stats != null) _buildStatsHeader(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadTrips,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _trips.length,
              itemBuilder: (context, index) => _TripCard(
                trip: _trips[index],
                onDelete: () => _deleteTrip(_trips[index]),
                onTap: () => _showTripDetails(_trips[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    final stats = _stats!;
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.route,
            value: stats.tripCount.toString(),
            label: 'Przejazdów',
          ),
          _StatItem(
            icon: Icons.straighten,
            value: '${stats.totalDistance.toStringAsFixed(0)} km',
            label: 'Łącznie',
          ),
          _StatItem(
            icon: Icons.timer,
            value: _formatDuration(stats.totalDuration),
            label: 'Czas jazdy',
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }

  void _showTripDetails(SavedTripInfo trip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _TripDetailsPage(tripInfo: trip)),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.onDelete,
    required this.onTap,
  });

  final SavedTripInfo trip;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.startTimeFormatted,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          trip.vehicleName ?? 'Przejazd',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: Colors.red.shade300,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _TripStat(
                    icon: Icons.straighten,
                    value: trip.distanceFormatted,
                  ),
                  _TripStat(icon: Icons.timer, value: trip.durationFormatted),
                  _TripStat(
                    icon: Icons.local_gas_station,
                    value: trip.fuelFormatted,
                  ),
                  _TripStat(
                    icon: Icons.data_usage,
                    value: '${trip.snapshotCount}',
                    tooltip: 'Zapisanych punktów',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripStat extends StatelessWidget {
  const _TripStat({required this.icon, required this.value, this.tooltip});

  final IconData icon;
  final String value;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final widget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(value, style: Theme.of(context).textTheme.bodySmall),
      ],
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: widget);
    }
    return widget;
  }
}

class _TripDetailsPage extends StatefulWidget {
  const _TripDetailsPage({required this.tripInfo});

  final SavedTripInfo tripInfo;

  @override
  State<_TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<_TripDetailsPage> {
  SavedTrip? _fullTrip;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFullTrip();
  }

  Future<void> _loadFullTrip() async {
    final trip = await TripStorage.instance.loadTrip(widget.tripInfo.path);
    setState(() {
      _fullTrip = trip;
      _isLoading = false;
    });
  }

  Future<void> _shareJson() async {
    await TripStorage.instance.shareTrip(
      widget.tripInfo.path,
      message: 'Przejazd z ${widget.tripInfo.startTimeFormatted}',
    );
  }

  Future<void> _shareCsv() async {
    try {
      await TripStorage.instance.shareTripAsCsv(widget.tripInfo.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Błąd eksportu: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły przejazdu'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.share),
            tooltip: 'Udostępnij',
            onSelected: (value) {
              if (value == 'json') _shareJson();
              if (value == 'csv') _shareCsv();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'json',
                child: ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Udostępnij JSON'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: ListTile(
                  leading: Icon(Icons.table_chart),
                  title: Text('Udostępnij CSV'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _fullTrip == null
          ? const Center(child: Text('Nie udało się wczytać przejazdu'))
          : _buildDetails(),
    );
  }

  Widget _buildDetails() {
    final trip = _fullTrip!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(trip),
          const SizedBox(height: 16),
          _buildTripDataCard(trip),
          const SizedBox(height: 16),
          if (trip.obdSnapshots.isNotEmpty) _buildSnapshotsPreview(trip),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(SavedTrip trip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Podsumowanie', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _DetailRow(label: 'Data', value: trip.startTimeFormatted),
            _DetailRow(label: 'Czas trwania', value: trip.durationFormatted),
            _DetailRow(
              label: 'Dystans',
              value: '${trip.distance.toStringAsFixed(1)} km',
            ),
            _DetailRow(
              label: 'Śr. spalanie',
              value: '${trip.avgFuelConsumption.toStringAsFixed(1)} l/100km',
            ),
            _DetailRow(
              label: 'Zużyte paliwo',
              value: '${trip.totalFuelUsed.toStringAsFixed(2)} l',
            ),
            _DetailRow(
              label: 'Zarejestrowane punkty',
              value: '${trip.obdSnapshots.length}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDataCard(SavedTrip trip) {
    final importantKeys = [
      'startFuelLvl',
      'currentFuelLvl',
      'usedFuel',
      'idleUsedFuel',
      'savedFuel',
      'distance',
      'tripSeconds',
      'idleTripSeconds',
      'rapidAccelerations',
      'rapidBreakings',
      'starts',
    ];

    final entries = trip.tripData.entries.where(
      (e) => importantKeys.contains(e.key) && e.value != null,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dane przejazdu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...entries.map(
              (e) => _DetailRow(
                label: _translateKey(e.key),
                value: _formatValue(e.value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnapshotsPreview(SavedTrip trip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dane OBD', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  '${trip.obdSnapshots.length} punktów',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Zapisane parametry pozwalają odtworzyć przejazd\nlub wyeksportować do analizy.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (trip.obdSnapshots.isNotEmpty)
              _buildFirstSnapshotPreview(trip.obdSnapshots.first),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstSnapshotPreview(OBDSnapshot snapshot) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Przykładowy snapshot:',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: snapshot.data.entries
                .take(8)
                .map(
                  (e) => Text(
                    '${e.key}: ${_formatValue(e.value)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  String _translateKey(String key) {
    const translations = {
      'startFuelLvl': 'Poziom paliwa (start)',
      'currentFuelLvl': 'Poziom paliwa (koniec)',
      'usedFuel': 'Zużyte paliwo (jazda)',
      'idleUsedFuel': 'Zużyte paliwo (postój)',
      'savedFuel': 'Zaoszczędzone paliwo',
      'distance': 'Dystans',
      'tripSeconds': 'Czas jazdy',
      'idleTripSeconds': 'Czas postoju',
      'rapidAccelerations': 'Gwałtowne przyspieszenia',
      'rapidBreakings': 'Gwałtowne hamowania',
      'starts': 'Liczba startów',
    };
    return translations[key] ?? key;
  }

  String _formatValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(2);
    }
    if (value is Duration) {
      return '${value.inMinutes}m ${value.inSeconds.remainder(60)}s';
    }
    return value.toString();
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
