import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitals/tabs/home/sub/health_scan.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';

class HomeWidget extends StatelessWidget {
  final String? accountType;

  const HomeWidget({super.key, required this.accountType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(FetchProfileEvent(accountType ?? "patient")),
      child: _HomeView(accountType: accountType ?? "patient"),
    );
  }
}

class _HomeView extends StatelessWidget {
  final String accountType;

  const _HomeView({required this.accountType});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF09090B) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {

          if (state is HomeLoading) {
            return Center(child: CupertinoActivityIndicator(radius: 16, color: isDark ? Colors.white : Colors.black));
          }

          if (state is HomeError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }

          if (state is HomeLoaded) {
            return accountType == "patient"
                ? _buildPatientUniverse(context, state, isDark, bgColor)
                : _buildClinicCommand(context, state, isDark, bgColor);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPatientUniverse(BuildContext context, HomeLoaded state, bool isDark, Color bgColor) {
    final textColor = isDark ? Colors.white : const Color(0xFF111111);
    final glassColor = isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03);
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.2);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 380,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 60),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo.shade900,
                      Colors.deepPurple.shade800,
                      Colors.purple.shade900,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Welcome back,", style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
                            Text(state.userName, style: GoogleFonts.outfit(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.person, color: Colors.white, size: 22),
                        )
                      ],
                    ),
                    const Spacer(),

                    Text("How are you feeling?", style: GoogleFonts.outfit(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthScanScreen())),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(CupertinoIcons.waveform_path_ecg, color: Colors.white, size: 20),
                                const SizedBox(width: 12),
                                Text("Run A Quick Scan", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: Icon(CupertinoIcons.arrow_right, color: Colors.purple.shade900, size: 14),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              Positioned(
                bottom: -35,
                left: 24,
                right: 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A24).withOpacity(0.8) : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                          ]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBioNode("Blood", state.bloodGroup, Colors.redAccent, textColor),
                          _buildDivider(borderColor),
                          _buildBioNode("Weight", "${state.weight} kg", Colors.orangeAccent, textColor),
                          _buildDivider(borderColor),
                          _buildBioNode("Height", "${state.height} cm", Colors.greenAccent, textColor),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 65),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Actions", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor, letterSpacing: -0.5)),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: _buildActionPill("Chat", "AI Doctor", CupertinoIcons.chat_bubble_text, Colors.purpleAccent, glassColor, borderColor, textColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildActionPill("Find", "Doctors", CupertinoIcons.search, Colors.blueAccent, glassColor, borderColor, textColor)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildActionPill("Book", "Appt.", CupertinoIcons.calendar, Colors.orangeAccent, glassColor, borderColor, textColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildActionPill("Pills", "Reminder", CupertinoIcons.bell_solid, Colors.greenAccent, glassColor, borderColor, textColor)),
                  ],
                ),
                const SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: glassColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3))
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
                        child: Icon(CupertinoIcons.folder_solid, color: bgColor, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Medi Locker", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                            Text("Manage medical docs", style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14)),
                          ],
                        ),
                      ),
                      Icon(CupertinoIcons.arrow_right, color: bgColor),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      state.dailyFact,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicCommand(BuildContext context, HomeLoaded state, bool isDark, Color bgColor) {
    final textColor = isDark ? Colors.white : const Color(0xFF111111);
    final glassColor = isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03);
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.2);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 380,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 60),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blueGrey.shade900,
                      Colors.blue.shade900,
                      Colors.indigo.shade800,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Greetings,", style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("${state.userName}", style: GoogleFonts.outfit(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: state.isEmergency ? Colors.redAccent.withOpacity(0.5) : Colors.white.withOpacity(0.2), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            child: const Icon(CupertinoIcons.person_fill, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                    const Spacer(),

                    Text("Management", style: GoogleFonts.outfit(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    Text("An apple a day keeps the doctor away", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15)),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              Positioned(
                bottom: -35,
                left: 24,
                right: 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A24).withOpacity(0.8) : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                          ]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildClinicStatNode("Appts", "12", Colors.blueAccent, textColor),
                          _buildDivider(borderColor),
                          _buildClinicStatNode("Pending", "3", Colors.orangeAccent, textColor),
                          _buildDivider(borderColor),
                          _buildClinicStatNode("Done", "8", Colors.greenAccent, textColor),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 65),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Emergency Status", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor, letterSpacing: -0.5)),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () => context.read<HomeBloc>().add(ToggleEmergencyEvent(state.isEmergency)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: state.isEmergency
                          ? LinearGradient(colors: [Colors.redAccent.withOpacity(0.15), Colors.red.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                          : null,
                      color: state.isEmergency ? null : glassColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: state.isEmergency ? Colors.redAccent.withOpacity(0.4) : borderColor),
                      boxShadow: state.isEmergency ? [
                        BoxShadow(color: Colors.redAccent.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))
                      ] : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: state.isEmergency ? Colors.redAccent.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            state.isEmergency ? CupertinoIcons.waveform_path_ecg : CupertinoIcons.moon_fill,
                            color: state.isEmergency ? Colors.redAccent : Colors.grey.shade500,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.isEmergency ? "URGENT CARE OPEN" : "OFFLINE FOR URGENT",
                                style: GoogleFonts.outfit(color: state.isEmergency ? Colors.redAccent : textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  state.isEmergency ? "Accepting critical walk-ins" : "Not accepting critical walk-ins",
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: state.isEmergency,
                          activeColor: Colors.redAccent,
                          onChanged: (val) => context.read<HomeBloc>().add(ToggleEmergencyEvent(state.isEmergency)),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Text("Up Next", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor, letterSpacing: -0.5)),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: glassColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Icon(CupertinoIcons.clock_fill, color: Colors.indigo, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Next Patient", style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("10:30 AM • Sarah J.", style: GoogleFonts.outfit(color: textColor, fontSize: 20, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      Icon(CupertinoIcons.chevron_right_circle_fill, color: textColor.withOpacity(0.2), size: 36),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicStatNode(String label, String value, Color accent, Color textColor) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -1)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ],
        )
      ],
    );
  }

  Widget _buildBioNode(String label, String value, Color accent, Color textColor) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600, letterSpacing: 1)),
          ],
        )
      ],
    );
  }

  Widget _buildDivider(Color color) {
    return Container(width: 1, height: 35, color: color);
  }

  Widget _buildActionPill(String title, String subtitle, IconData icon, Color accent, Color glassColor, Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: glassColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 28),
          const SizedBox(height: 20),
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}