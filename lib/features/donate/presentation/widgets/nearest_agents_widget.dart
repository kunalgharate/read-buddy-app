import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_buddy_app/features/donate/domain/entities/agent.dart';

class NearestAgentsWidget extends StatelessWidget {
  final List<Agent> agents;

  const NearestAgentsWidget({super.key, required this.agents});

  static const _primaryGreen = Color(0xFF2CE07F);
  static const _textDark = Color(0xFF052E44);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final paddingH = size.width * 0.05;

    return SingleChildScrollView(
      padding: EdgeInsets.all(paddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nearest Pickup Agents',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select an agent to schedule book pickup',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF7A9BB5),
            ),
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: agents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final agent = agents[index];
              return _buildAgentCard(agent);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(Agent agent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: agent.isAvailable
              ? const Color(0xFFE0E0E0)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _primaryGreen.withValues(alpha: 0.1),
                child: Text(
                  agent.name.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            agent.name,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: agent.isAvailable
                                ? _primaryGreen.withValues(alpha: 0.1)
                                : const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            agent.isAvailable ? 'Available' : 'Busy',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: agent.isAvailable
                                  ? _primaryGreen
                                  : const Color(0xFF7A9BB5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFA726),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${agent.rating}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${agent.totalDeliveries} deliveries',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF7A9BB5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xFF7A9BB5),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  agent.location.address,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF7A9BB5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.directions_car_outlined,
                size: 16,
                color: Color(0xFF7A9BB5),
              ),
              const SizedBox(width: 6),
              Text(
                '${agent.distanceKm.toStringAsFixed(1)} km away',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF7A9BB5),
                ),
              ),
              if (agent.estimatedPickupTimeMin != null) ...[
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Color(0xFF7A9BB5),
                ),
                const SizedBox(width: 6),
                Text(
                  '~${agent.estimatedPickupTimeMin} min',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF7A9BB5),
                  ),
                ),
              ],
            ],
          ),
          if (agent.isAvailable) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  // Handle agent selection
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Select Agent',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
