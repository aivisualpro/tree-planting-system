<script setup lang="ts">
definePageMeta({
  layout: 'blank',
  auth: false,
})
</script>

<template>
  <div class="max-w-4xl mx-auto p-8 prose dark:prose-invert">
    <h1>Privacy Policy</h1>
    <p><strong>Effective Date:</strong> April 24, 2026</p>
    <p><strong>Version:</strong> 1.0.0</p>

    <p>This Privacy Policy explains how our NGO ("we", "us", "our") collects, uses, and shares your information when you use our Tree-Planting System application and website.</p>

    <h2>1. Data We Collect</h2>
    <p>We collect the following personal information:</p>
    <ul>
      <li><strong>Identity Data:</strong> Name, email address, WhatsApp number.</li>
      <li><strong>Technical Data:</strong> Device ID, IP address, crash reporting data.</li>
      <li><strong>Location Data:</strong> GPS coordinates during field visits.</li>
      <li><strong>Media:</strong> Photos taken during site visits.</li>
    </ul>

    <h2>2. How We Use Your Data</h2>
    <p>Your data is used for the following purposes:</p>
    <ul>
      <li>Facilitating field operations and tracking tree planting progress.</li>
      <li>Generating compliance and operational reports.</li>
      <li>Account management and authentication.</li>
      <li>Application stability monitoring and crash reporting.</li>
    </ul>

    <h2>3. Third-Party Data Processors</h2>
    <p>We share necessary data with trusted third parties to operate our services:</p>
    <ul>
      <li><strong>Supabase:</strong> Database and authentication hosting.</li>
      <li><strong>Vercel:</strong> Web frontend hosting.</li>
      <li><strong>Sentry:</strong> Crash and error reporting.</li>
      <li><strong>Resend:</strong> Email delivery.</li>
      <li><strong>Firebase Cloud Messaging (FCM):</strong> Push notifications.</li>
      <li><strong>Meta (WhatsApp):</strong> Messaging services.</li>
    </ul>

    <h2>4. Data Retention</h2>
    <p>We retain your data per our <a href="/terms">Data Retention Policy</a>. Generally, field data is retained as long as required for reporting and verification, after which it is anonymized.</p>

    <h2>5. Your Rights</h2>
    <p>Depending on your jurisdiction, you have the right to:</p>
    <ul>
      <li><strong>Access:</strong> Request a copy of your data.</li>
      <li><strong>Export:</strong> Receive your data in a portable format (e.g., ZIP).</li>
      <li><strong>Delete:</strong> Request the deletion of your account and personal data.</li>
      <li><strong>Object:</strong> Object to specific processing of your data.</li>
    </ul>

    <h2>6. Jurisdictional Compliance</h2>
    <h3>European Union (GDPR)</h3>
    <p>If you are in the EU, you have additional rights under the GDPR. Our lawful basis for processing is performance of a contract and legitimate interest.</p>
    <h3>Tanzania (DPA 2022) & Malawi (DPA 2024)</h3>
    <p>We comply with regional data protection requirements in Tanzania and Malawi, including local registration and explicit consent protocols.</p>

    <h2>7. Contact Information</h2>
    <p>If you have any questions or wish to exercise your rights, please contact our Data Protection Officer (DPO) at compliance@example.org.</p>
  </div>
</template>
