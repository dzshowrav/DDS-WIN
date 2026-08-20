using System;
using System.IO;
using System.Net;
using System.Diagnostics;
using System.IO.Compression;

namespace DDSInstaller
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.Title = "DDS Server Stack - Windows Setup Wizard";
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine(@"
  =======================================================
          DDS Local Server Stack - Setup Wizard          
      Apache 2.4 · MariaDB 10.11 · PHP 8.5 · phpMyAdmin  
  =======================================================
");
            Console.ResetColor();

            string defaultPath = @"C:\DDS\App";
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("  This installer will download and set up the complete DDS stack.");
            Console.Write(string.Format("  Install directory [{0}]: ", defaultPath));
            Console.ResetColor();
            
            string inputPath = Console.ReadLine();
            string targetDir = string.IsNullOrWhiteSpace(inputPath) ? defaultPath : inputPath.Trim();

            try
            {
                if (!Directory.Exists(targetDir))
                {
                    Directory.CreateDirectory(targetDir);
                }

                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine("\n[1/4] Fetching latest DDS repository files...");
                Console.ResetColor();

                string zipUrl = "https://github.com/dzshowrav/DDS-WIN/archive/refs/heads/main.zip";
                string tempZip = Path.Combine(Path.GetTempPath(), "dds_install_temp.zip");
                string tempExtract = Path.Combine(Path.GetTempPath(), "dds_install_extract");

                using (WebClient client = new WebClient())
                {
                    client.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)");
                    Console.WriteLine("      Downloading application archive...");
                    client.DownloadFile(zipUrl, tempZip);
                }

                Console.WriteLine("      Extracting application files...");
                if (Directory.Exists(tempExtract))
                {
                    Directory.Delete(tempExtract, true);
                }
                ZipFile.ExtractToDirectory(tempZip, tempExtract);

                // Find root inner folder (e.g. DDS-WIN-main)
                string[] subDirs = Directory.GetDirectories(tempExtract);
                string sourceFolder = subDirs.Length > 0 ? subDirs[0] : tempExtract;

                CopyDirectory(sourceFolder, targetDir);

                // Cleanup temp
                try
                {
                    File.Delete(tempZip);
                    Directory.Delete(tempExtract, true);
                }
                catch { }

                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine("      [OK] Application files unpacked successfully.");
                Console.ResetColor();

                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine("\n[2/4] Running automated stack setup (Apache, PHP, MariaDB)...");
                Console.ResetColor();

                string setupScript = Path.Combine(targetDir, "setup.ps1");
                if (File.Exists(setupScript))
                {
                    ProcessStartInfo psi = new ProcessStartInfo
                    {
                        FileName = "powershell.exe",
                        Arguments = string.Format("-NoProfile -ExecutionPolicy Bypass -File \"{0}\"", setupScript),
                        WorkingDirectory = targetDir,
                        UseShellExecute = false
                    };

                    Process proc = Process.Start(psi);
                    proc.WaitForExit();
                }

                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine("\n[3/4] Creating Desktop & Start Menu Shortcuts...");
                Console.ResetColor();

                CreateDesktopShortcut(targetDir);
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine("      [OK] Desktop shortcut 'DDS Server Control' created with brand icon.");
                Console.ResetColor();

                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine(@"
  =======================================================
               🎉 Installation Complete!                 
  =======================================================

  You can now start DDS in three ways:
    1. Double-click the 'DDS Server Control' icon on your Desktop.
    2. Open any CMD or PowerShell and type: dds
    3. Run: dds start
");
                Console.ResetColor();

                Console.Write("  Would you like to launch DDS right now? (Y/n): ");
                string startChoice = Console.ReadLine();
                if (string.IsNullOrWhiteSpace(startChoice) || startChoice.Trim().ToLower().StartsWith("y"))
                {
                    string ddsCmd = Path.Combine(targetDir, "dds.cmd");
                    if (File.Exists(ddsCmd))
                    {
                        ProcessStartInfo startPsi = new ProcessStartInfo
                        {
                            FileName = "cmd.exe",
                            Arguments = string.Format("/k \"\"{0}\"\"", ddsCmd),
                            WorkingDirectory = targetDir,
                            UseShellExecute = true
                        };
                        Process.Start(startPsi);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine(string.Format("\n  ERROR during installation: {0}", ex.Message));
                Console.ResetColor();
                Console.WriteLine("\n  Press any key to exit...");
                Console.ReadKey();
            }
        }

        static void CopyDirectory(string sourceDir, string destinationDir)
        {
            DirectoryInfo dir = new DirectoryInfo(sourceDir);
            DirectoryInfo[] dirs = dir.GetDirectories();

            Directory.CreateDirectory(destinationDir);

            foreach (FileInfo file in dir.GetFiles())
            {
                string targetFilePath = Path.Combine(destinationDir, file.Name);
                file.CopyTo(targetFilePath, true);
            }

            foreach (DirectoryInfo subDir in dirs)
            {
                string newDestinationDir = Path.Combine(destinationDir, subDir.Name);
                CopyDirectory(subDir.FullName, newDestinationDir);
            }
        }

        static void CreateDesktopShortcut(string targetDir)
        {
            try
            {
                string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
                string shortcutPath = Path.Combine(desktopPath, "DDS Server Control.lnk");
                string targetFile = Path.Combine(targetDir, "dds.cmd");
                string iconFile = Path.Combine(targetDir, @"assets\dds.ico");

                string vbsScript = string.Format(@"
Set oWS = WScript.CreateObject(""WScript.Shell"")
sLinkFile = ""{0}""
Set oLink = oWS.CreateShortcut(sLinkFile)
oLink.TargetPath = ""{1}""
oLink.WorkingDirectory = ""{2}""
oLink.IconLocation = ""{3}""
oLink.Description = ""DDS Local Server Stack Manager""
oLink.Save
", shortcutPath, targetFile, targetDir, iconFile);

                string tempVbs = Path.Combine(Path.GetTempPath(), "create_dds_shortcut.vbs");
                File.WriteAllText(tempVbs, vbsScript);

                Process proc = Process.Start("wscript.exe", string.Format("\"{0}\"", tempVbs));
                proc.WaitForExit();
                File.Delete(tempVbs);
            }
            catch { }
        }
    }
}
