// Wait for the DOM to load
document.addEventListener('DOMContentLoaded', function () {
    const announcementForm = document.getElementById('announcement-form');
    const announcementList = document.getElementById('announcement-list');

    // Dummy data for current announcements (could be fetched from a database in a real application)
    const announcements = [
        {
            title: "Holiday Schedule",
            body: "Our service will be unavailable on the 25th of December due to the holiday season.",
        },
        {
            title: "New Route Added",
            body: "A new route from Huamak to Mega is now available at 10 AM daily.",
        },
    ];

    // Function to display announcements
    function displayAnnouncements() {
        // Clear the announcement list
        announcementList.innerHTML = '';

        // Add each announcement to the list
        announcements.forEach((announcement, index) => {
            const announcementElement = document.createElement('div');
            announcementElement.classList.add('announcement');

            const titleElement = document.createElement('h3');
            titleElement.textContent = announcement.title;

            const bodyElement = document.createElement('p');
            bodyElement.textContent = announcement.body;

            const editButton = document.createElement('button');
            editButton.textContent = 'Edit';
            editButton.classList.add('button', 'edit');
            editButton.addEventListener('click', () => editAnnouncement(index));

            const deleteButton = document.createElement('button');
            deleteButton.textContent = 'Delete';
            deleteButton.classList.add('button', 'delete');
            deleteButton.addEventListener('click', () => deleteAnnouncement(index));

            announcementElement.appendChild(titleElement);
            announcementElement.appendChild(bodyElement);
            announcementElement.appendChild(editButton);
            announcementElement.appendChild(deleteButton);

            announcementList.appendChild(announcementElement);
        });
    }

    // Function to handle form submission
    announcementForm.addEventListener('submit', function (e) {
        e.preventDefault();

        const title = document.getElementById('announcement-title').value;
        const body = document.getElementById('announcement-body').value;

        // Add the new announcement to the announcements array
        announcements.push({ title, body });

        // Clear the form
        announcementForm.reset();

        // Re-render the announcement list
        displayAnnouncements();
    });

    // Function to handle editing announcements
    function editAnnouncement(index) {
        const announcement = announcements[index];
        document.getElementById('announcement-title').value = announcement.title;
        document.getElementById('announcement-body').value = announcement.body;

        // Optionally, add logic to replace or update the announcement when saved
        // Could open a modal to edit announcement as well
    }

    // Function to handle deleting announcements
    function deleteAnnouncement(index) {
        // Remove the announcement from the array
        announcements.splice(index, 1);

        // Re-render the announcement list
        displayAnnouncements();
    }

    // Display initial announcements
    displayAnnouncements();
});
