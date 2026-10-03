# USS
Ubuntu Environment Setup Script for Mobile-Friendly Terminal
How to Use

```bash
# 1. Make it executable
chmod +x ~/setup-ubuntu.sh

# 2. Run it
~/setup-ubuntu.sh
```

📱 Mobile-Friendly Design Principles Used

Principle Why it matters on mobile
Short lines (rule, wrapped output) Fits narrow phone screens
Numbered menus Easy to tap a single key
Single-key choices No long typing on soft keyboard
Persistent toggles Change settings without re-running everything
Short aliases (gs, ll, ..) Saves typing on tiny keyboards
Compact prompt Fits more commands without wrapping
Clear ✓/✗ icons Visible even with small fonts
Confirm before reset Prevents accidental damage

🔧 Optional: Add a Floating Shortcut

Add to ~/.bashrc so you can launch it anytime with one word:

```bash
alias setup='~/setup-ubuntu.sh'
```

Then just type setup on your phone.

💡 Tips for Mobile Terminals (Termux, JuiceSSH, etc.)

1. Use TMUX — install via the script, then tmux new -s work to survive disconnects
2. Enable compact mode — toggle #2 for a tiny ~ $ prompt
3. Enable aliases — toggle #3 to save typing
4. Landscape mode — some menus wrap better sideways
5. SSH from phone — ssh user@ip then run setup

🎯 Suggested Workflow

```
1) First run → choose option 1 (update)
2) Then option 2 (essentials)
3) Then option 3 → d (all dev tools)
4) Option 5 → turn ON aliases + compact
5) Option 4 → zsh (optional, nicer prompt)
```
