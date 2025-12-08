import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../utils/openMap.dart';
import '../viewmodel/location_viewmodel.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String _formatDate(DateTime dt) => DateFormat('hh:mm a • dd MMM yyyy').format(dt);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LocationViewmodel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current Location', style: Theme.of(context).textTheme.titleMedium),
                        if (vm.isTracking)
                          Row(
                            children: const [
                              Icon(Icons.fiber_manual_record, size: 12, color: Colors.red),
                              SizedBox(width: 6),
                              Text('Tracking', style: TextStyle(fontSize: 12, color: Colors.red)),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    vm.currentPosition == null
                        ? const Text('Coordinates: —')
                        : Text(
                            'Lat: ${vm.currentPosition!.latitude.toStringAsFixed(5)}, '
                            'Lng: ${vm.currentPosition!.longitude.toStringAsFixed(5)}',
                          ),

                    const SizedBox(height: 8),

                    vm.currentAddress == null
                        ? const Text('Address: Not available', style: TextStyle(color: Colors.grey))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('City: ${vm.currentAddress!.city}'),
                              Text('State: ${vm.currentAddress!.state}'),
                              Text('Pincode: ${vm.currentAddress!.pincode}'),
                            ],
                          ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        vm.lastUpdated == null
                            ? const Text('Last updated: —', style: TextStyle(fontSize: 12))
                            : Text('Last updated: ${_formatDate(vm.lastUpdated!)}',
                                style: const TextStyle(fontSize: 12)),
                        if (vm.isLoading) const SizedBox(width: 120, child: LinearProgressIndicator()),
                      ],
                    ),

                    if (vm.error != null) ...[
                      const SizedBox(height: 8),
                      Text('Error: ${vm.error}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: vm.isLoading ? null : () => vm.fetchOnce(),
                    icon: const Icon(Icons.my_location),
                    label: const Text('Get Location'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: vm.isTracking ? vm.stopTracking : vm.startTracking,
                  icon: Icon(vm.isTracking ? Icons.pause : Icons.play_arrow),
                  label: Text(vm.isTracking ? 'Stop' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vm.isTracking ? Colors.orange : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('History', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: vm.history.isEmpty ? null : vm.clearHistory,
                  child: const Text('Clear'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Expanded(
              child: vm.history.isEmpty
                  ? const Center(child: Text('No history yet', style: TextStyle(color: Colors.grey)))
                  : ListView.separated(
                      itemCount: vm.history.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = vm.history[vm.history.length - 1 - index];
                        final formattedTime = DateFormat('hh:mm a • dd MMM').format(item.timestamp);

                        return ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.place_outlined, size: 20),
                            ],
                          ),
                          title: Text(item.address.city),
                          subtitle: Text(
                            'Lat: ${item.lat.toStringAsFixed(5)}, Lng: ${item.long.toStringAsFixed(5)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(formattedTime, style: const TextStyle(fontSize: 12)),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Time: $formattedTime', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text('Coordinates: ${item.lat}, ${item.long}'),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Clipboard.setData(ClipboardData(
                                              text: '${item.lat}, ${item.long}',
                                            ));
                                          },
                                          icon: const Icon(Icons.copy),
                                          label: const Text('Copy'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            openMap(item.lat, item.long);
                                            Navigator.of(context).pop();
                                          },
                                          icon: const Icon(Icons.map),
                                          label: const Text('Open Map'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}