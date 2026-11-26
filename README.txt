ECE241 PACKAGE SORTER - PROJECT SOURCE

This export contains the custom package-sorter modules and testbenches identified
in the working project. Source contents and existing module-folder paths are
preserved. Different versions in top/, time_control/, and vga/ remain separate;
these folders are not intended to be compiled together into one library.

Distinct .v.bak source versions are preserved under legacy-backups/.
source-manifest.csv maps uploaded files to their original paths and SHA-256 hashes.
Milestone 2 was empty at export time.

Excluded: bundled VGA examples and demos, supplied VGA adapter/controller/address
translator, generated PLL, supplied Altera PS2 modules, sample memory images,
Quartus/ModelSim build products, waveforms, project UI state, and assignment PDF.

The custom vga_conveyor module is adapted from example code; existing comments
and attribution have been preserved. Inclusion is based on project-specific
content, not a verified authorship history.

DEPENDENCIES
This is a source-only archive, not a complete standalone FPGA build. VGA designs
still require the matching course VGA adapter, controller, address translator,
PLL and memory images, plus the appropriate Intel simulation libraries.
Obtain these from the original course support package. Local project files and
support dependencies remain in the original working folder.

KNOWN EXISTING DIFFERENCES
The standalone VGA module uses eight-bit RGB outputs; its testbench has scalar
RGB wires. The integrated top/ version also uses scalar RGB outputs and differs
in its adapter wiring and background colour. These were not changed for export.
The VGA testbench is too short to show a full screen draw.

This guide and export manifest were prepared with Codex. No simulation or FPGA
validation was performed for this export.
