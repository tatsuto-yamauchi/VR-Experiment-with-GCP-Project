const express = require('express');
const path = require('path');
const { google } = require('googleapis');
const fs = require('fs');
const multer = require('multer');

const app = express();

// Set up Google Drive API credentials.
const auth = new google.auth.GoogleAuth({
  keyFile: 'credentials.json',
  scopes: ['https://www.googleapis.com/auth/drive'],
});


// Function to get the number of files in a folder
async function getFilesCountInFolder(folderId) {
  try {
    // Create a Google Drive client
    const client = await auth.getClient();
    const drive = google.drive({ version: 'v3', auth: client });

    let filesCount = 0;
    let nextPageToken = null;

    do {
      // Get a list of files in a folder.
      const response = await drive.files.list({
        q: `'${folderId}' in parents`,
        fields: 'files',
        pageSize: 1000,
        pageToken: nextPageToken,
      });

      const files = response.data.files;
      filesCount += files.length;

      nextPageToken = response.data.nextPageToken;
    } while (nextPageToken);

    // console.log(`Number of files in the folder: ${filesCount}`);
    return filesCount;
  } catch (error) {
    console.error('Error retrieving files count:', error);
  }
}

// Folder ID
const CSVfolderId = '1P1efzPboyOy0-CBip__9Ue5WGewjXXgO';


// Create middleware to handle file uploads.
const upload = multer({
  dest: 'uploads/', // Specifies the directory where temporary files are stored.
});

app.post('/upload', upload.single('file'), async (req, res) => {
  if (req.file) {
    const file = req.file;
    console.log(file);

    const fileNum = await getFilesCountInFolder(CSVfolderId) + 1 ;
    const CSVfileName = 'data'+fileNum+'.csv'
    console.log(CSVfileName);
    
    const client = await auth.getClient();
    const drive = google.drive({ version: 'v3', auth: client });

    //upload file to drive
    const response = await drive.files.create({
      requestBody: {
        name: CSVfileName, // File name on Google Drive
        parents: [CSVfolderId], // folder ID
      },
      media: {
        mimeType: 'text/csv',
        body: fs.createReadStream(file.path), // Upload files using streams.
      },
    });

    // Delete temporary uploaded files.
    fs.unlinkSync(file.path);

    res.send('File uploaded successfully');
  } else {
    res.status(400).send('No file uploaded');
  }
});

app.use(express.static('public'));

// Port number to start the server.
const port = 3000;
// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

// Response to a GET request for a route.
app.get('/', (req, res) => {
  // res.sendFile(path.join(__dirname, 'index.html'));
  // res.sendFile(path.join(__dirname, 'exp_cylinder.html'));
  //res.sendFile(path.join(__dirname, 'exp_human-static.html'));
  // res.sendFile(path.join(__dirname, 'exp_robot.html'));
  res.sendFile(path.join(__dirname, 'exp_human-animation.html'));
});